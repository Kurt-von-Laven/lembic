class Block < ActiveRecord::Base
  attr_accessible :name, :created_at, :updated_at
  
  validates_presence_of :name
  
  has_many :block_inputs
  has_many :block_connections
  
end
