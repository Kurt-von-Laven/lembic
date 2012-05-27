class BlockConnection < ActiveRecord::Base
  attr_accessible :id, :block_id, :expression_string, :expression_object, :next_block_id, :created_at, :updated_at, :sort_index
  
  validates_presence_of :block_id, :expression_string, :expression_object, :next_block_id, :sort_index
  validates_numericality_of :block_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  serialize :expression_object
  
  belongs_to :block
  belongs_to :next_block, :class_name => "Block", :foreign_key => "next_block_id"
  
end
