class CategoryOption < ActiveRecord::Base
  attr_accessible :id, :block_variable_id, :name, :value, :description, :created_at, :updated_at
  
  belongs_to :block_variable
  
  validates_presence_of :name, :value
  validates_uniqueness_of :name, :scope => [:block_variable_id]
  validates_uniqueness_of :value, :scope => [:block_variable_id]
  validates_numericality_of :block_variable_id, :only_integer => true, :greater_than => 0
  
end
