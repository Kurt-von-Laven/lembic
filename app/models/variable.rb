class Variable < ActiveRecord::Base
  attr_accessible :name, :description, :workflow_id, :variable_type, :array, :created_at, :updated_at, :expression_string, :expression_object
  
  DEFAULT_OPTIONS = {'array' => 0}
  
  # type is an integer in range X to X, inclusive.  The mapping is as follows:
  #
  #
  
  validates_uniqueness_of :name, :scope => :workflow_id, :message => "Variable names must be unique."
  validates :name, presence: true
  
  validates :variable_type, presence: true
  validates_inclusion_of :variable_type, :in => 0..3, :message => "Invalid variable type. If you're seeing this message, we goofed."
    
  validates :workflow_id, presence: true
  # validates_associated :workflow
  belongs_to :workflow
  
  validates :array, presence: true
  validates_inclusion_of :array, :in => 0..1, :message => "That is not a boolean.  What did you DO?!?!"
  
  validates :created_at, presence: true
  validates :updated_at, presence: true
  
  def self.create_from_form(form_hash)
    now = Time.now
    Permission.where(:user_id => 1).first_or_create({'workflow_id' => 1, 'permissions' => 4, 'created_at' => now, 'updated_at' => now})
    User.where(:first_name => 'Michael').first_or_create({'last_name' => 'Jones', 'email' => 'qweoui@adsfqw.com', 'organization' => 'City Team',
                                                               'pwd_hash' => '21ad42ef24123589abcd', 'created_at' => now, 'updated_at' => now})
    Workflow.where(:name => 'Sample Workflow').first_or_create({'description' => 'This record should be removed eventually and is just for test purposes.',
                                                                     'created_at' => now, 'updated_at' => now})
    merged_var = DEFAULT_OPTIONS.merge(form_hash)
    merged_var['created_at'] = now
    merged_var['updated_at'] = now
    merged_var['workflow_id'] = 1 # TODO: Grab the workflow ID out of the session state.
    merged_var['variable_type'] = merged_var['variable_type'].to_i
    merged_var['array'] = merged_var['array'].to_i
    if merged_var['expression_string'].empty?
      merged_var['expression_string'] = nil
    else
      parser = Parser.new
      merged_var['expression_object'] = parser.parse(merged_var['expression_string'])
    end
    Variable.create(merged_var)
  end
  
  def self.create_constant_array(form_hash)
    now = Time.now
    Permission.where(:user_id => 1).first_or_create({'workflow_id' => 1, 'permissions' => 4, 'created_at' => now, 'updated_at' => now})
    User.where(:first_name => 'Michael').first_or_create({'last_name' => 'Jones', 'email' => 'qweoui@adsfqw.com', 'organization' => 'City Team',
                                                               'pwd_hash' => '21ad42ef24123589abcd', 'created_at' => now, 'updated_at' => now})
    Workflow.where(:name => 'Sample Workflow').first_or_create({'description' => 'This record should be removed eventually and is just for test purposes.',
                                                                     'created_at' => now, 'updated_at' => now})
    merged_array = DEFAULT_OPTIONS.merge(form_hash)
    merged_array['created_at'] = now
    merged_array['updated_at'] = now
    merged_array['workflow_id'] = 1 # TODO: Grab the workflow ID out of the session state.
    merged_array['variable_type'] = merged_array['variable_type'].to_i
    merged_array['array'] = 1
    data_file = merged_array['data_file']
    puts data_file.read
    merged_array.delete('data_file')
    merged_array.delete('column_number')
    merged_array.delete('row_number')
  end
  
end
