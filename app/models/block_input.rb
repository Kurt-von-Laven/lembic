class BlockInput < ActiveRecord::Base
  attr_accessible :block_id, :sort_index, :variable
  
  belongs_to :block
  
end
