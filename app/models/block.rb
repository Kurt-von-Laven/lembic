class Block < ActiveRecord::Base
  attr_accessible :name
  
  has_many :block_connections
  
end
