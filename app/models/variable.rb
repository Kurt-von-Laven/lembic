require 'csv'
require Rails.root.join('app/helpers/expression')
require Rails.root.join('app/models/index_name')

class Variable < ActiveRecord::Base
  
  include PersistableExpressions
  
  attr_accessible :id, :name, :description, :workflow_id, :variable_type, :array, :created_at, :updated_at, :expression_string, :expression_object
  
  validates_presence_of :name, :workflow_id, :variable_type, :array
  validates_numericality_of :workflow_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :variable_type, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 3
  validates_numericality_of :array, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 1
  
  validates_uniqueness_of :name, :scope => :workflow_id, :message => "must be unique; delete the existing variable first."
  
  serialize :expression_object
  
  belongs_to :workflow
  
  has_many :index_names
  has_many :block_inputs, :dependent => :destroy
  
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
    return "#{name.split(/\s*\[\s*/)[0]}" + ((index_names().empty?) ? '' : "[#{index_names().collect{|i| i.name}.join(",")}]")
  end

  def self.create_from_form(form_hash, user_id)
    Permission.where(:user_id => user_id).first_or_create({'workflow_id' => user_id, 'permissions' => 4})
    Workflow.where(:id => user_id, :name => 'Sample Workflow').first_or_create({'description' => 'This record should be removed eventually and is just for test purposes.'})
    merged_var = {'array' => 0}.merge(form_hash)
    merged_var['workflow_id'] = user_id # TODO: Grab the workflow ID out of the session state.
    merged_var['variable_type'] = merged_var['variable_type'].to_i
    merged_var['array'] = merged_var['array'].to_i
    merged_var['name'] = merged_var['name'].split(/\s*\[/)[0]
    if merged_var['expression_string'].empty?
      merged_var['expression_string'] = nil
    end
    new_var = Variable.new(merged_var)
    new_var.save
    IndexName.create_from_declaration(form_hash['name'], new_var.id)
  end
  
  def self.create_constant_array(form_hash, user_id)
    Permission.where(:user_id => user_id).first_or_create({'workflow_id' => user_id, 'permissions' => 4})
    Workflow.where(:id => user_id, :name => 'Sample Workflow').first_or_create({'description' => 'This record should be removed eventually and is just for test purposes.'})
    merged_array = {'array' => 0, 'start_row' => 1, 'column_number' => 1}.merge(form_hash)
    merged_array['name'] += "[#{INDEX}]"
    merged_array['workflow_id'] = user_id # TODO: Grab the workflow ID out of the session state.
    merged_array['variable_type'] = merged_array['variable_type'].to_i
    merged_array['array'] = 1
    data = merged_array['data_file'].read
    merged_array['expression_string'] = self.parse_csv_expression(data, merged_array['start_row'].to_i, merged_array['column_number'].to_i,
                                                                  merged_array['variable_type'])
    merged_array.delete('data_file')
    merged_array.delete('start_row')
    merged_array.delete('column_number')
    newvar = Variable.create(merged_array)
    IndexName.create_from_declaration("[#{INDEX}]", newvar.id)
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
    desired_rows = parsed_data[start_row, num_rows_desired]
    desired_column = desired_rows.map {|r| r[column_number]}
    desired_column_with_nans = desired_column.map {|v| (v.nil? or (v == '')) ? Float::NAN : v}
    desired_values_as_str = desired_column_with_nans.join(', ')
    return "[ #{INDEX} | #{desired_values_as_str}]"
  end
  
end
