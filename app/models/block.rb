class Block < ActiveRecord::Base
  attr_accessible :id, :name, :workflow_id, :created_at, :updated_at, :display_type, :sort_index
  
  validates_presence_of :name, :workflow_id, :sort_index
  validates_numericality_of :workflow_id, :only_integer => true, :greater_than => 0
  
  validates_uniqueness_of :sort_index, :scope => :workflow_id
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  has_many :originating_connections, :class_name => "BlockConnection", :foreign_key => "next_block_id", :dependent => :destroy
  has_many :block_variables, :dependent => :destroy
  has_many :block_connections, :dependent => :destroy
  has_many :runs
  has_many :workflow_blocks, :dependent => :destroy
  validates_associated :originating_connections, :block_variables, :block_connections, :runs, :workflow_blocks
  belongs_to :workflow
  
  def outputs_string # getter returnsempty string. TODO: Fix this and create a setter 
	result = String.new
  end 
  def connections_string # getter returnsempty string. TODO: Fix this and create a setter 
	result = String.new
  end 
  
  def inputs_string  # TODO: Needs to return string of input variables -Kseniya
	block_variables.order(:sort_index)
	myString = String.new
  end

  # Create a block_variable for the variable named on each line of the input string
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
      sort_index = block_variables.size

      # Create a block input with the specified variable
      bi = block_variables.create({:variable_id => variable.id, :sort_index => sort_index})
      if bi.nil?
        # TODO: Return an error to the user
        logger.debug "Failed to create block_variable with variable_id => #{variable.id} and sort_index => #{sort_index}"
      end
    end
  end
  
  # Decrement higher sort_indexs to prevent sparseness
  after_destroy do |destroyed|
    # NOTE: I'm not quite sure if this is atomic, may need to wrap in a transaction -Tom
    Block.transaction do
      Block.where("workflow_id = ? AND sort_index > ?", destroyed.workflow_id, destroyed.sort_index).each do |b|
        b.sort_index = b.sort_index - 1
        b.save :validate => false # Validation was causing problems since it may not go in order
      end
    end
  end
end
