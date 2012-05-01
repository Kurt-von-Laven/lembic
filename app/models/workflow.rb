class Workflow < ActiveRecord::Base
  attr_accessible :name, :description, :created_at, :updated_at
  
  validates :name, :presence => true
  validates_uniqueness_of :name
  
  validates :description, :presence => true
  
  has_many :variables
  validates_associated :variables
  
  has_many :users, :through => :permissions
  validates_associated :permissions
  
  validates :created_at, :presence => true
  validates :updated_at, :presence => true
  
end
