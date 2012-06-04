class Run < ActiveRecord::Base
  attr_accessible :block_id, :user_id, :workflow_id, :description, :completed_at

  validates_presence_of :block_id
  validates_presence_of :user_id
  validates_presence_of :workflow_id
  
  belongs_to :user
  belongs_to :workflow
  belongs_to :block
  
end
