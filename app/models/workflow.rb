class Workflow < ActiveRecord::Base
  attr_accessible :id, :name, :description, :created_at, :updated_at
  
  validates_presence_of :name, :description
  
  validates_uniqueness_of :name
  
  has_many :users, :through => :workflow_permissions
  
  has_many :variables
  has_many :blocks, :dependent => :destroy
  has_many :runs
  validates_associated :variables, :blocks, :runs
  
end
