class BlockConnection < ActiveRecord::Base
  attr_accessible :id, :block_id, :expression_string, :expression_object, :next_block, :created_at, :updated_at, :sort_index
  
  validates_presence_of :block_id, :expression_string, :expression_object, :sort_index
  validates_numericality_of :block_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  serialize :expression_object
  
  belongs_to :block
  
end
