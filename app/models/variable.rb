require 'csv'
require Rails.root.join('app/helpers/expression')
require Rails.root.join('app/models/index_name')

class Variable < ActiveRecord::Base
  attr_accessible :id, :name, :description, :model_id, :variable_type, :array, :created_at, :updated_at, :expression_string, :expression_object
  
  include PersistableExpressions
  
  validates_presence_of :name, :model_id, :variable_type, :array
  validates_numericality_of :model_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :variable_type, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 3
  validates_numericality_of :array, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1
  
  validates_uniqueness_of :name, :scope => :model_id, :message => "must be unique; delete the existing variable first."
  
  serialize :expression_object
  
  belongs_to :model
  
  has_many :index_names, :dependent => :destroy
  has_many :block_variables, :dependent => :destroy
  has_many :run_values
  
  validates_associated :index_names, :block_variables, :run_values
  
  INDEX = 'i' # The index used for constant arrays.
 
  # The variable type is represented as an integer in range [0, 3] according to this mapping.
  def variable_type_string
    var = case variable_type
          when 0
            'Categorical'
          when 1
            'Integer'
          when 2
            'Real'
          when 3
            'Date and Time'
          end
    if array?
      var += ' Array'
    end
    return var
  end
  
  def array?
    return array == 1
  end
  
  def name_with_indices
    return "#{name.split(/\s*\[\s*/)[0]}" + (array? ? "[#{index_names.collect{|i| i.name}.join(",")}]" : '')
  end
  
  def name_with_indices=(new_name)
    name = new_name.split(/\s*\[\s*/)[0]
    if new_name.match(/\[.+\]/)
      IndexName.delete_all(["variable_id = ?", self.id])
      IndexName.create_from_declaration(new_name, self.id)
    end
  end
  
  def index_name_strings
    sorted_index_names = index_names.order(:sort_index)
    if sorted_index_names.empty?
      return nil
    end
    return sorted_index_names.collect { |i| i.name }
  end

  def self.create_from_form(form_hash, user_id)
    merged_var = {'array' => 0}.merge(form_hash)
    merged_var['model_id'] = user_id # TODO: Grab the model ID out of the session state.
    merged_var['variable_type'] = merged_var['variable_type'].to_i
    merged_var['array'] = merged_var['name'].match(/\[.+\]/) ? 1 : 0
    puts "CREATED VARIABLE: ARRAY = #{merged_var['array']}"
    merged_var['name'] = merged_var['name'].split(/\s*\[/)[0]
    if merged_var['expression_string'].empty?
      merged_var['expression_string'] = nil
    end
    new_var = Variable.new(merged_var)
    new_var.save
    IndexName.create_from_declaration(form_hash['name'], new_var.id)
  end
  
  def self.create_constant_array(form_hash, user_id)
    merged_array = {'array' => 0, 'start_row' => 1, 'column_number' => 1}.merge(form_hash)
    merged_array['model_id'] = user_id # TODO: Grab the model ID out of the session state.
    merged_array['variable_type'] = merged_array['variable_type'].to_i
    merged_array['array'] = 1
    data = merged_array['data_file'].read
    merged_array['expression_string'] = self.parse_csv_expression(data,
                                                                  merged_array['start_row'].to_i,
                                                                  self.convert_letter_column_labels_to_numbers(merged_array['column_number']),
                                                                  merged_array['variable_type'])
    merged_array.delete('data_file')
    merged_array.delete('start_row')
    merged_array.delete('column_number')
    newvar = Variable.create(merged_array)
    IndexName.create_from_declaration("[#{INDEX}]", newvar.id)
  end
  
  def self.convert_letter_column_labels_to_numbers(input)
    raise ArgumentError, "parameter of convert_letter_column_labels_to_numbers must be a string" if !input.instance_of?(String)
    if input.match(/^[0-9]+$/)
      return input.to_i
    end
    if input.match(/^[a-zA-Z]+$/)
      multiplier = 1
      output = 0
      input.upcase.reverse.each_byte do |b|
	index_in_alphabet = b - 'A'[0].ord + 1
	output += index_in_alphabet * multiplier
	multiplier *= 26
      end
      return output
    end
    raise ArgumentError, "Column label must be specified as a decimal number or an Excel-style letter label."
  end
  
  def self.parse_csv_expression(csv_data, start_row_one_indexed, column_number_one_indexed, variable_type)
    start_row = start_row_one_indexed - 1
    column_number = column_number_one_indexed - 1
    converter = case variable_type
                when 0
                  nil
                when 1
                  :integer
                when 2
                  :float
                when 3
                  :date_time
                end
    parsed_data = CSV.parse(csv_data, :converters => converter)
    num_rows_desired = parsed_data.length - start_row
    if num_rows_desired < 1
      #start_row was greater than the greatest index in the array
      raise ArgumentError, "Start row out of bounds; can be at most #{parsed_data.length}" #remember that the user inputs one-indexed values!
    end
    desired_rows = parsed_data[start_row, num_rows_desired]
    desired_column = desired_rows.map {|r| r[column_number]}
    desired_column_with_nans = desired_column.map {|v| (v.nil? or (v == '')) ? Float::NAN : v}
    if converter == :date_time
      #convert to Lembic datetime
      desired_column_with_nans = desired_column_with_nans.collect{|i| date_convert(i)}
    end
    desired_values_as_str = desired_column_with_nans.join(', ')
    return "[ #{INDEX} | #{desired_values_as_str}]"
  end
  
  def self.date_convert(input)
    puts "DATE CONVERTER INPUT #{input.inspect}"
    if !input.instance_of?(String)
      return input
    end
    # converts an Excel-formatted date/time string to Lembic format.
    puts "DATE CONVERTER INPUT = #{input}"
    date = nil
    #try a bunch of different formats
    date = try_date_conversion_format(input, "%m/%d/%y %H:%M") if date.nil?
    date = try_date_conversion_format(input, "%m/%d/%Y %H:%M") if date.nil?
    date = try_date_conversion_format(input, "%m/%d/%y %l:%M %p") if date.nil?
    date = try_date_conversion_format(input, "%m/%d/%Y %l:%M %p") if date.nil?
    date = try_date_conversion_format(input, "%H:%M") if date.nil?
    date = try_date_conversion_format(input, "%l:%M %p") if date.nil?
    date = try_date_conversion_format(input, "%H:%M:%S") if date.nil?
    date = try_date_conversion_format(input, "%l:%M:%S %p") if date.nil?
    conv = date.strftime("%Y_%m_%d_%H_%M_%S")
    puts "CONVERTED = #{conv}"
    return conv
    
  end
  
  def self.try_date_conversion_format(input, fmt)
    date = nil
    begin
      date = DateTime.strptime(input, fmt)
    rescue
    end
    return date
  end
  
end
