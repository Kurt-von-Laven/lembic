class RunValue < ActiveRecord::Base
  attr_accessible :id, :run_id, :variable_id, :index_values, :value
  
  serialize :index_values
  
  validates_presence_of :variable_id, :run_id, :value
  validates_uniqueness_of :index_values, :scope => [:variable_id, :run_id]
  
  belongs_to :run
  belongs_to :variable
end
