class Workflow < ActiveRecord::Base
  attr_accessible :name, :description, :created_at, :updated_at
  
  validates_presence_of :name, :description
  
  validates_uniqueness_of :name
  
  has_many :variables
  # validates_associated :variables
  
  has_many :users, :through => :permissions
  # validates_associated :permissions
  
  has_many :blocks
  # validates_associated :blocks
  
end
