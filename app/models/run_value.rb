class RunValue < ActiveRecord::Base
  attr_accessible :id, :run_id, :variable_id, :index_values, :value, :created_at, :updated_at
  
  serialize :index_values
  
  validates_presence_of :variable_id, :run_id, :value
  validates_uniqueness_of :index_values, :scope => [:variable_id, :run_id]
  validates_numericality_of :run_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :variable_id, :only_integer => true, :greater_than => 0
  
  belongs_to :run
  belongs_to :variable
end
