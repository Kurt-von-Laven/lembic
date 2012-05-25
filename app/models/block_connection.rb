class BlockConnection < ActiveRecord::Base
  attr_accessible :block_id, :expression_string, :expression_object, :next_block, :created_at, :updated_at, :sort_index
  
  validates_presence_of :block_id, :expression_string, :expression_object, :sort_index
  
  serialize :expression_object
  
  belongs_to :block
  
end
