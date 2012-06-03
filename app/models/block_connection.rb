class BlockConnection < ActiveRecord::Base
  
  include PersistableExpressions
  
  attr_accessible :id, :block_id, :expression_string, :expression_object, :next_block_id, :created_at, :updated_at, :sort_index
  
  validates_presence_of :block_id, :expression_string, :expression_object, :next_block_id, :sort_index
  
  # Prevent 2 records from getting the same sort_index
  validates_uniqueness_of :sort_index, :scope => :block_id
  
  validates_numericality_of :block_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  serialize :expression_object
  
  belongs_to :block
  belongs_to :next_block, :class_name => "Block", :foreign_key => "next_block_id"
  
  after_destroy do |block_connection|
    # Decrement higher sort_indexs to prevent sparseness
    # NOTE: I'm not quite sure if this is atomic, may need to wrap in BlockConnection.transaction -Tom
    BlockConnection.where("sort_index > ?", block_connection.sort_index) do |bc|
      bc.sort_index = bc.sort_index - 1
    end
  end
  
end
