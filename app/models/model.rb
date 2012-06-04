class Model < ActiveRecord::Base
  
  # Associations
  has_many :permissions, :dependent => :destroy
  has_many :variables, :dependent => :destroy
  has_many :workflows, :dependent => :destroy
  
  # Validators
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  validates_associated :permissions, :variables, :workflows
  
  # Attribute accessors
  attr_accessible :id, :description, :name
  
end
