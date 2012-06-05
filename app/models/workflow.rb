class Workflow < ActiveRecord::Base
  attr_accessible :id, :name, :description, :model_id, :created_at, :updated_at
  
  validates_presence_of :name, :description
  
  validates_uniqueness_of :name, :scope => :model_id
  
  has_many :users, :through => :workflow_permissions
  
  has_many :blocks, :dependent => :destroy
  has_many :runs
  validates_associated :blocks, :runs
  
  belongs_to :model
  
end
