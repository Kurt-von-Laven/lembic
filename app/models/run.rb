class Run < ActiveRecord::Base
  attr_accessible :id, :block_id, :user_id, :workflow_id, :description, :completed_at, :created_at, :updated_at
  
  validates_presence_of :block_id, :user_id, :workflow_id
  
  belongs_to :user
  belongs_to :workflow
  belongs_to :block
  
  has_many :run_values
  
  validates_associated :run_values
  
end
