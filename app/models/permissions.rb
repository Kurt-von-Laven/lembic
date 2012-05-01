class Permission < ActiveRecord::Base
  attr_accessible :user_id, :workflow_id, :permissions, :created_at, :updated_at
  
  has_many :users
  has_many :workflows
  validates_uniqueness_of :user_id, :scope => :workflow_id
  
  validates :user_id, :presence => true
  validates :workflow_id, :presence => true
  validates :permissions, :presence => true
  
  validates :created_at, :presence => true
  validates :updated_at, :presence => true
end
