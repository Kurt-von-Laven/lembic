class Workflow < ActiveRecord::Base
  attr_accessible :id, :name, :description, :model_id, :created_at, :updated_at, :sort_index
  
  SORT_INDEX_SCOPE = :model_id
  
  include CondenseSortIndices
  
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => :model_id
  validates_numericality_of :model_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  validates_associated :blocks, :runs
  
  has_many :workflow_permissions
  has_many :users, :through => :workflow_permissions
  has_many :blocks, :dependent => :destroy
  has_many :runs
  
  belongs_to :model
  
  def blocks_as_string
    sorted_block_names = blocks.order(:sort_index).pluck(:name)
    return sorted_block_names.join("\n")
  end
  
end
