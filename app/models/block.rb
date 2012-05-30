class Block < ActiveRecord::Base
  attr_accessible :id, :name, :workflow_id, :created_at, :updated_at, :display_type
  
  validates_presence_of :name, :workflow_id
  validates_numericality_of :workflow_id, :only_integer => true, :greater_than => 0
  
  has_many :originating_connections, :class_name => "BlockConnection", :foreign_key => "next_block_id", :dependent => :destroy
  has_many :block_inputs, :dependent => :destroy
  has_many :block_connections, :dependent => :destroy
  validates_associated :block_inputs, :block_connections
  belongs_to :workflow
  
  def outputs_string # getter returnsempty string. TODO: Fix this and create a setter 
	result = String.new
  end 
  def connections_string # getter returnsempty string. TODO: Fix this and create a setter 
	result = String.new
  end 
  
  def inputs_string  # TODO: Needs to return string of input variables -Kseniya
	block_inputs.order(:sort_index)
	myString = String.new
  end

  # Create a block_input for the variable named on each line of the input string
  def inputs_string=(string)
    
    # Iterate through each line of the input string
    string.lines do |line|

      # Trim the line to get a variable name
      variable_name = line.strip
      if variable_name.empty? # TODO: get better input validation
        next
      end
      
      # Find the variable
      variable = Variable.find_by_name(variable_name)
      if variable.nil?
        logger.debug "Could not find variable '#{variable_name}' by name"
        next
      end

      # Determine sort_index
      sort_index = block_inputs.size

      # Create a block input with the specified variable
      bi = block_inputs.create({:variable_id => variable.id, :sort_index => sort_index})
      if bi.nil?
        # TODO: Return an error to the user
        logger.debug "Failed to create block_input with variable_id => #{variable.id} and sort_index => #{sort_index}"
      end
    end
  end
end
