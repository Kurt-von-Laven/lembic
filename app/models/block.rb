class Block < ActiveRecord::Base
  attr_accessible :id, :name, :workflow_id, :created_at, :updated_at, :display_type
  
  validates_presence_of :name, :workflow_id
  validates_numericality_of :workflow_id, :only_integer => true, :greater_than => 0
  
  has_many :originating_connections, :class_name => "block_connection"
  has_many :block_inputs, :dependent => :destroy
  has_many :block_connections, :dependent => :destroy
  validates_associated :block_inputs, :block_connections
  belongs_to :workflow
  
  def inputs_string 
	block_inputs.order(:sort_index)
	
  end
  
  def inputs_string=(string) 
	string.lines do |line|
          
    # Trim the line to get a variable name
    variable_name = line.strip
	 if variable_name.empty? # TODO: get better input validation
        next
     end
          
     # Determine sort_index
     sort_index = 0
          
      # Create a block input with the specified variable
      block_inputs.create({:variable => variable_name, :sort_index => sort_index})
	end
  end
end
