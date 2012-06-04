class WorkflowPermission < ActiveRecord::Base
  attr_accessible :id, :user_id, :workflow_id, :permissions, :created_at, :updated_at
  
  validates_presence_of :user_id, :workflow_id, :permissions
  validates_numericality_of :user_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :workflow_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :permissions, :only_integer => true, :greater_than => 0
  
  validates_uniqueness_of :user_id, :scope => :workflow_id
  
  has_many :users
  has_many :workflows
  validates_associated :users, :workflows
  
end
