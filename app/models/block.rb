class Block < ActiveRecord::Base
  attr_accessible :name, :workflow_id, :created_at, :updated_at
  
  validates_presence_of :name, :workflow_id
  
  has_many :block_inputs
  has_many :block_connections
  belongs_to :workflow
  
end
