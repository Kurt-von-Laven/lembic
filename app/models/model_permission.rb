class ModelPermission < ActiveRecord::Base
  
  # Associations
  belongs_to :model
  belongs_to :user
  
  # Validators
  validates_presence_of :permissions, :sort_index, :model_id, :user_id
  validates_uniqueness_of :sort_index, :scope => :user_id
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  # Attribut accessors
  attr_accessible :id, :permissions, :sort_index, :model_id, :user_id
  
end
