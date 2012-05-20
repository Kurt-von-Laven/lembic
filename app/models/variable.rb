require 'csv'

class Variable < ActiveRecord::Base
  attr_accessible :name, :description, :workflow_id, :variable_type, :array, :created_at, :updated_at, :expression_string, :expression_object
  
  validates_presence_of :name, :workflow_id, :variable_type, :array
  
  validates_uniqueness_of :name, :scope => :workflow_id, :message => 'Variable names must be unique.'
  
  validates_inclusion_of :variable_type, :in => 0..3, :message => 'Invalid variable type. If you\'re seeing this message, we goofed.'
  
  validates_inclusion_of :array, :in => 0..1, :message => 'That is not a boolean.  What did you DO?!?!'
  
  serialize :expression_object
  
  # validates_associated :workflow
  belongs_to :workflow
  
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
	if array == 1
		var += " Array"
	 end
	 return var
  end

	
 
  
  def self.create_from_form(form_hash, user_id)
    Permission.where(:user_id => user_id).first_or_create({'workflow_id' => user_id, 'permissions' => 4})
    Workflow.where(:name => 'Sample Workflow').first_or_create({'description' => 'This record should be removed eventually and is just for test purposes.'})
    merged_var = {'array' => 0}.merge(form_hash)
    merged_var['workflow_id'] = user_id # TODO: Grab the workflow ID out of the session state.
    merged_var['variable_type'] = merged_var['variable_type'].to_i
    merged_var['array'] = merged_var['array'].to_i
    if merged_var['expression_string'].empty?
      merged_var['expression_string'] = nil
    else
      parser = Parser.new
    begin
      merged_var['expression_object'] = parser.parse(merged_var['expression_string'])
    rescue ArgumentError, SystemCallError, IOError, RuntimeError
        raise ArgumentError, "An unexpected error occured saving your variable. Please try again."
    end
    Variable.create(merged_var)
end 
            
  end
  
  def self.create_constant_array(form_hash, user_id)
    Permission.where(:user_id => user_id).first_or_create({'workflow_id' => user_id, 'permissions' => 4})
    User.where(:first_name => 'Michael').first_or_create({'last_name' => 'Jones', 'email' => 'qweoui@adsfqw.com', 'organization' => 'City Team',
                                                           'pwd_hash' => Digest::SHA512.hexdigest('raasdqweqjkladsfi'),
                                                           'salt' => Digest::SHA512.hexdigest('raasdqweqjkladsfi')})
    Workflow.where(:name => 'Sample Workflow').first_or_create({'description' => 'This record should be removed eventually and is just for test purposes.'})
    merged_array = {'array' => 0, 'start_row' => 0, 'column_number' => 0}.merge(form_hash)
    merged_array['name'] += "[#{INDEX}]"
    merged_array['workflow_id'] = user_id # TODO: Grab the workflow ID out of the session state.
    merged_array['variable_type'] = merged_array['variable_type'].to_i
    merged_array['array'] = 1
    data = merged_array['data_file'].read()
    merged_array['expression_string'] = self.parse_csv_expression(data, merged_array['start_row'].to_i, merged_array['column_number'].to_i,
                                                                  merged_array['variable_type'])
    parser = Parser.new
    puts merged_array['expression_string']
    merged_array['expression_object'] = parser.parse(merged_array['expression_string'])
    merged_array.delete('data_file')
    merged_array.delete('start_row')
    merged_array.delete('column_number')
    Variable.create(merged_array)
  end
  
  def self.parse_csv_expression(csv_data, start_row, column_number, variable_type)
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
    desired_column_with_nans = desired_column.map {|v| v.nil? or '' ? Float::NAN : v}
    desired_values_as_str = desired_column_with_nans.join(', ')
    return "[ #{INDEX} | #{desired_values_as_str}]"
  end
  
end
