class Variable < ActiveRecord::Base
  attr_accessible :name, :description, :workflow_id, :variable_type, :array, :created_at, :updated_at, :expression_string, :expression_object

  # type is an integer in range X to X, inclusive.  The mapping is as follows:
  #
  #
  
  validates_uniqueness_of :name, :scope => :workflow_id, :message => "Variable names must be unique."
  validates :name, presence: true
  
  validates :variable_type, presence: true
  validates_inclusion_of :variable_type, :in => 0..3, :message => "Invalid variable type. If you're seeing this message, we goofed."
  
  validates :description, presence: true
  
  validates :workflow_id, presence: true
  # validates_associated :workflow
  belongs_to :workflow
  
  validates :array, presence: true
  validates_inclusion_of :array, :in => 0..1, :message => "That is not a boolean.  What did you DO?!?!"
  
  validates :created_at, presence: true
  validates :updated_at, presence: true
  
  validates :expression_string, presence: true
  validates :expression_object, presence: true
  
end
