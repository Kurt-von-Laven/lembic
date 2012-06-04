class CategoryOption < ActiveRecord::Base
  attr_accessible :id, :block_variable_id, :name, :value, :description
  
  belongs_to :block_variable
  
  validates_presence_of :name
  validates_presence_of :value
  validates_presence_of :description
  validates_uniqueness_of :name, :scope => [:block_variable_id]
  validates_uniqueness_of :value, :scope => [:block_variable_id]
  
end
