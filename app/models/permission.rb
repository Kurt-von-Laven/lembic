class Permission < ActiveRecord::Base
  attr_accessible :user_id, :workflow_id, :permissions, :created_at, :updated_at
  
  validates_presence_of :user_id, :workflow_id, :permissions
  
  validates_uniqueness_of :user_id, :scope => :workflow_id
  
  has_many :users
  has_many :workflows
  
end
