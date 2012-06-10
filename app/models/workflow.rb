class Workflow < ActiveRecord::Base
  attr_accessible :id, :name, :description, :model_id, :created_at, :updated_at
  
  SORT_INDEX_SCOPE = :model_id
  
  include CondenseSortIndices
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :model_id
  validates_associated :workflow_permissions, :blocks, :runs
  
  has_many :workflow_permissions, :dependent => :destroy
  has_many :users, :through => :workflow_permissions
  has_many :blocks, :dependent => :destroy
  has_many :runs
  
  belongs_to :model
  
end
