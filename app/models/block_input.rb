class BlockInput < ActiveRecord::Base
  attr_accessible :block_id, :sort_index, :variable, :created_at, :updated_at
  
  validates_presence_of :block_id, :sort_index, :variable
  
  belongs_to :block
  
end
