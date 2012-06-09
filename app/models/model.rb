class Model < ActiveRecord::Base
  attr_accessible :id, :description, :name, :model_id, :user_id
  
  # Associations
  has_many :model_permissions
  has_many :users, :through => :model_permissions
  has_many :variables, :dependent => :destroy
  has_many :workflows, :dependent => :destroy
  
  # Validators
  validates_presence_of :name, :description
  validates_uniqueness_of :name
  validates_associated :variables, :workflows
  
end
