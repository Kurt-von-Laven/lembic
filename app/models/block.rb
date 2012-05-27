class Block < ActiveRecord::Base
  attr_accessible :id, :name, :workflow_id, :created_at, :updated_at, :display_type
  
  validates_presence_of :name, :workflow_id
  validates_numericality_of :workflow_id, :only_integer => true, :greater_than => 0
  
  has_many :originating_connections, :class_name => "block_connection"
  has_many :block_inputs, :dependent => :destroy
  has_many :block_connections, :dependent => :destroy
  validates_associated :block_inputs, :block_connections
  belongs_to :workflow
  
end
