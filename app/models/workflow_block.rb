class WorkflowBlock < ActiveRecord::Base
  attr_accessible :workflow_id, :block_id, :sort_index
  
  #sort index stores the index of the block with
  
  belongs_to :block
  belongs_to :workflow
  validates_presence_of :workflow_id
  validates_presence_of :block_id
  validates_presence_of :sort_index
  validates_uniqueness_of :workflow_id, :scope => [:block_id]
  validates_uniqueness_of :sort_index, :scope => [:workflow_id]
end
