class Variable < ActiveRecord::Base
  attr_accessible :name, :description, :workflow_id, :type, :array, :const, :created_at, :updated_at

  # type is an integer in range X to X, inclusive.  The mapping is as follows:
  #
  #
  
  validates_uniqueness_of :name, :scope => :workflow_id, :message => "Variable names must be unique."
  validates :name, presence: true
  
  validates :type, presence: true
  validates_inclusion_of :type, :in => 0..3, :message => "Invalid type. If you're seeing this message, we goofed."
  
  validates :description, presence: true
  
  validates :workflow_id, presence: true
  validates_associated :workflow
  belongs_to :workflow
  
  validates :array, presence: true
  validates_inclusion_of :array, :in => 0..1, :message => "That is not a boolean.  What did you DO?!?!"
  
  validates :const, presence: true
  validates_inclusion_of :const, :in => 0..1, :message => "That is not a boolean.  What did you DO?!?!"
  
  validates :created_at, presence: true
  validates :updated_at, presence: true
  
end
