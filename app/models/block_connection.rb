class BlockConnection < ActiveRecord::Base
  attr_accessible :id, :block_id, :expression_string, :expression_object, :next_block_id, :created_at, :updated_at, :sort_index
  
  validates_presence_of :block_id, :expression_string, :expression_object, :next_block_id, :sort_index
  
  # Prevent 2 records from getting the same sort_index
  validates_uniqueness_of :sort_index, :scope => :block_id
  
  validates_numericality_of :block_id, :only_integer => true, :greater_than => 0
  validates_numericality_of :sort_index, :only_integer => true, :greater_than_or_equal_to => 0
  
  serialize :expression_object
  
  belongs_to :block
  belongs_to :next_block, :class_name => "Block"
  
  after_destroy do |destroyed|
    # Decrement higher sort_indexs to prevent sparseness
    # NOTE: I'm not quite sure if this is atomic, may need to wrap in BlockConnection.transaction -Tom
    BlockConnection.transaction do
      BlockConnection.where("block_id = ? AND sort_index > ?", destroyed.block_id, destroyed.sort_index) do |bc|
        bc.sort_index = bc.sort_index - 1
        bc.save :validate => false # Validation was causing problems since it may not go in order
      end
    end
  end
  
end
