class BlockConnection < ActiveRecord::Base
  attr_accessible :block_id, :expression, :next_block, :created_at, :updated_at
  
  validates_presence_of :block_id, :expression
  
  belongs_to :block
  
end
