require 'csv'
require 'csv_importer'
require Rails.root.join('app/helpers/expression')
require Rails.root.join('app/models/index_name')

class Variable < ActiveRecord::Base
  attr_accessible :id, :name, :description, :model_id, :variable_type, :array, :created_at, :updated_at, :expression_string, :expression_object, :name_with_indices
  
  include PersistableExpressions
  
  validates_presence_of :name, :model_id, :variable_type, :array
  validates_numericality_of :model_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :variable_type, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 3
  validates_numericality_of :array, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1
  
  validates_uniqueness_of :name, :scope => :model_id, :message => "must be unique; delete the existing variable first"
  
  serialize :expression_object
  
  belongs_to :model
  
  has_many :index_names, :dependent => :destroy
  has_many :block_variables, :dependent => :destroy
  has_many :run_values
  
  validates_associated :index_names, :block_variables, :run_values
  
  
 
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
  
  def input?
    return expression_object.nil?
  end
  
  def name_with_indices
    return "#{name.split(/\s*\[\s*/)[0]}" + (array? ? "[#{index_names.collect{|i| i.name}.join(",")}]" : '')
  end
  
  def name_with_indices=(new_name)
    self.name = new_name.split(/\s*\[\s*/)[0]
    IndexName.delete_all(["variable_id = ?", self.id])
    if new_name.match(/\[.+\]/)
      IndexName.create_from_declaration(new_name, self.id)
      self.array = 1
    else
      self.array = 0
    end
  end
  
  def index_name_strings
    sorted_index_names = index_names.order(:sort_index)
    if sorted_index_names.empty?
      return nil
    end
    return sorted_index_names.collect { |i| i.name }
  end

  def self.create_from_form(form_hash, model_id)
    merged_var = form_hash
    merged_var['model_id'] = model_id
    merged_var['variable_type'] = merged_var['variable_type'].to_i
    if merged_var['expression_string'].empty?
      merged_var['expression_string'] = nil
    end
    new_var = Variable.new(merged_var)
    save_succeeded = new_var.save!
    IndexName.create_from_declaration(form_hash['name_with_indices'], new_var.id)
    return save_succeeded
  end
  
  def self.create_constant_array(form_hash, model_id)
    merged_array = {'array' => 1, 'start_row' => 1, 'column_number' => 1}.merge(form_hash)
    merged_array['model_id'] = model_id
    merged_array['variable_type'] = merged_array['variable_type'].to_i
    data = merged_array['data_file'].read
    merged_array['expression_string'] = CsvImporter.parse_csv_expression(data,
                                                                  merged_array['start_row'].to_i,
                                                                  CsvImporter.convert_letter_column_labels_to_numbers(merged_array['column_number']),
                                                                  merged_array['variable_type'])
    merged_array.delete('data_file')
    merged_array.delete('start_row')
    merged_array.delete('column_number')
    new_var = Variable.create(merged_array)
    IndexName.create_from_declaration("#{new_var.name}[#{CsvImporter::INDEX}]", new_var.id)
  end
end
