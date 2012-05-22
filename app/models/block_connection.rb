class BlockConnection < ActiveRecord::Base
  attr_accessible :block_id, :expression_string, :expression_object, :next_block, :created_at, :updated_at
  
  validates_presence_of :block_id, :expression_string, :expression_object
  
  serialize :expression_object
  
  belongs_to :block
  
end
