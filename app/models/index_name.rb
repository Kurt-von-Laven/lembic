class IndexName < ActiveRecord::Base
  attr_accessible :name, :variable_id, :position
  belongs_to :variable
  validates_uniqueness_of :name, :scope => :variable_id
  validates_uniqueness_of :position, :scope => :variable_id
end
