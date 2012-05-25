class Block < ActiveRecord::Base
  attr_accessible :name, :workflow_id, :created_at, :updated_at, :display_type
  
  validates_presence_of :name, :workflow_id, :display_type
  
  has_many :block_inputs, :dependent => :destroy
  has_many :block_connections, :dependent => :destroy
  belongs_to :workflow
  
end
