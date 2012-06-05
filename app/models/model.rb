class Model < ActiveRecord::Base
  attr_accessible :id, :description, :name
  
  # Associations
  has_many :model_permissions, :dependent => :destroy
  has_many :variables, :dependent => :destroy
  has_many :workflows, :dependent => :destroy
  
  # Validators
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  validates_associated :variables, :workflows
  
end
