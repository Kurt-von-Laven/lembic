class Block < ActiveRecord::Base
  attr_accessible :id, :name, :workflow_id, :created_at, :updated_at, :sort_index
  
  SORT_INDEX_SCOPE = :workflow_id
  
  include CondenseSortIndices
  
  validates_presence_of :name, :workflow_id, :sort_index
  validates_numericality_of :workflow_id, :only_integer => true, :greater_than => 0
  
  validates_uniqueness_of :name, :scope => :workflow_id
  validates_uniqueness_of :sort_index, :scope => :workflow_id
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  has_many :originating_connections, :class_name => "BlockConnection", :foreign_key => "next_block_id", :dependent => :destroy
  has_many :block_variables, :dependent => :destroy
  has_many :block_connections, :dependent => :destroy
  has_many :runs
  validates_associated :originating_connections, :block_variables, :block_connections, :runs
  belongs_to :workflow
  
  def output_variables_as_string # TODO: Create a corresponding setter. 
    return variables_as_string(false)
  end
  
  def input_variables_as_string # TODO: Create a corresponding setter.
    return variables_as_string(true)
  end
  
  def variables_as_string(is_input)
    display_type = is_input ? 0 : 1
    sorted_block_variables = block_variables.where(:display_type => display_type).order(:sort_index)
    variable_names = sorted_block_variables.collect do |block_variable|
        block_variable.variable.name
    end
    return variable_names.join("\n")
  end
  
  def connections_as_string # TODO: Create a corresponding setter.
    to_return = ''
    sorted_block_connections = block_connections.order(:sort_index)
    for block_connection in sorted_block_connections
      next_block_name = Block.find(block_connection.next_block_id).name
      to_return += "#{block_connection.expression_string} => #{next_block_name}\n"
    end
    return to_return
  end
  
end
