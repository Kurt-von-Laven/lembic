class WorkflowBlock < ActiveRecord::Base
  attr_accessible :id, :workflow_id, :block_id, :sort_index
  
  # sort_index stores the index of the block within the workflow (and not the other way around).
  
  belongs_to :block
  belongs_to :workflow
  validates_presence_of :workflow_id, :block_id, :sort_index
  validates_uniqueness_of :workflow_id, :scope => [:block_id]
  validates_uniqueness_of :sort_index, :scope => [:workflow_id]
end
