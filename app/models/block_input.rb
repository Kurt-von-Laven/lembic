class BlockInput < ActiveRecord::Base
  attr_accessible :id, :block_id, :sort_index, :variable_id, :created_at, :updated_at
  
  validates_presence_of :block_id, :sort_index, :variable_id
  
  # Prevent 2 records from getting the same sort_index
  validates_uniqueness_of :sort_index, :scope => :block_id
  
  validates_numericality_of :block_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  belongs_to :block
  belongs_to :variable
  
  after_destroy do |destroyed|
    # Decrement higher sort_indexs to prevent sparseness
    # NOTE: I'm not quite sure if this is atomic, may need to wrap in a transaction -Tom
    BlockInput.transaction do
      BlockInput.where("block_id = #{destroyed.block_id} AND sort_index > #{destroyed.sort_index}").each do |bi|
        bi.sort_index = bi.sort_index - 1
        bi.save :validate => false # Validation was causing problems since it may not go in order
      end
    end
  end
    
end
