class BlockConnection < ActiveRecord::Base
  attr_accessible :block_id, :expression, :next_block
  
  belongs_to :block
  
end
