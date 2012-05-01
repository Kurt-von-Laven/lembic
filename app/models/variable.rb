class Variable < ActiveRecord::Base
  attr_accessible :name, :type

  # type is an integer in range X to X, inclusive.  The mapping is as follows:
  #
  #
  
  belongs_to :workflow
  
  validates_uniqueness_of :name, :scope => :workflow_id
  validates(:name, presence: true)
  validates(:type, presence: true)
  validates_associated :workflow
end
