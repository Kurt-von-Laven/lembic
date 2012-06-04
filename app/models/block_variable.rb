class BlockVariable < ActiveRecord::Base
  attr_accessible :id, :block_id, :sort_index, :variable_id, :created_at, :updated_at, :prompt, :description, :formatting
  
  validates_presence_of :block_id, :sort_index, :variable_id, :display_type
  
  # Prevent 2 records from getting the same sort_index
  validates_uniqueness_of :sort_index, :scope => :block_id
  
  validates_numericality_of :block_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  belongs_to :block
  belongs_to :variable
  
  has_many :category_options
  
  validates_associated :category_options
  
  def display_type #returns :input or :output
    if self[:display_type] == 0
      return :input
    elsif self[:display_type] == 1
      return :output
    end
    raise RuntimeError, "display_type invalid!"
  end
  
  def display_type=(t) #t is :input or :output
    if t == :input
      self[:display_type] = 0
    elsif t == :output
      self[:display_type] = 1
    else
      raise ArgumentError "parameter to display_type=() must be :input or :output"
    end
  end
  
  after_destroy do |destroyed|
    # Decrement higher sort_indexs to prevent sparseness
    # NOTE: I'm not quite sure if this is atomic, may need to wrap in a transaction -Tom
    BlockVariable.transaction do
      BlockVariable.where("block_id = ? AND sort_index > ?", destroyed.block_id, destroyed.sort_index).each do |bi|
        bi.sort_index = bi.sort_index - 1
        bi.save :validate => false # Validation was causing problems since it may not go in order
      end
    end
  end
    
end
