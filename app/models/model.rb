class Model < ActiveRecord::Base
  
  # Associations
  has_many :model_permissions, :dependent => :destroy
  has_many :variables, :dependent => :destroy
  has_many :workflows, :dependent => :destroy
  
  # Validators
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  validates_associated :model_permissions, :variables, :workflows
  
  # Attribute accessors
  attr_accessible :id, :description, :name
  
end
