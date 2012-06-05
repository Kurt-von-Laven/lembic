class Block < ActiveRecord::Base
  attr_accessible :id, :name, :workflow_id, :created_at, :updated_at, :sort_index
  
  SORT_INDEX_SCOPE = :workflow_id
  
  include CondenseSortIndices
  
  validates_presence_of :name, :workflow_id, :sort_index
  validates_numericality_of :workflow_id, :only_integer => true, :greater_than => 0
  
  validates_uniqueness_of :name, :scope => :workflow_id
  validates_uniqueness_of :sort_index, :scope => :workflow_id
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  has_many :originating_connections, :class_name => "BlockConnection", :foreign_key => "next_block_id", :dependent => :destroy
  has_many :block_variables, :dependent => :destroy
  has_many :block_connections, :dependent => :destroy
  has_many :runs
  validates_associated :originating_connections, :block_variables, :block_connections, :runs
  belongs_to :workflow
  
  def outputs_string # getter returns empty string. TODO: Fix this and create a setter 
    return ''
  end
  
  def inputs_string
    return ''
  end
  
  def connections_string # getter returns empty string. TODO: Fix this and create a setter 
    return ''
  end
  
end
