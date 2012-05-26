class BlockInput < ActiveRecord::Base
  attr_accessible :id, :block_id, :sort_index, :variable, :created_at, :updated_at
  
  validates_presence_of :block_id, :sort_index, :variable
  
  validates_numericality_of :block_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  belongs_to :block
  
end
