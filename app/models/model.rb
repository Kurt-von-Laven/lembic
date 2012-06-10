class Model < ActiveRecord::Base
  attr_accessible :id, :description, :name, :created_at, :updated_at
  
  # Associations
  has_many :model_permissions, :dependent => :destroy
  has_many :users, :through => :model_permissions
  has_many :variables, :dependent => :destroy
  has_many :workflows, :dependent => :destroy
  
  # Validators
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_associated :model_permissions, :variables, :workflows
  
end
