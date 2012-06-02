class AddSortIndexToBlock < ActiveRecord::Migration
  
  ### Faux model allowing this migration to save data without running validations.
  ### Prevents issues associated with the current models trying to validate fields
  ### that aren't in the database yet as of this migration.
  ### For more info, see:
  ### http://guides.rubyonrails.org/migrations.html#using-models-in-your-migrations
  class Block < ActiveRecord::Base
    attr_accessible :sort_index
  end
  
  def change
    
    # Add column
    add_column :blocks, :sort_index, :integer
    
    # Set sort_index for existing records
    Block.reset_column_information
    Workflow.all.each do |w|
      count = 0
      w.blocks.all.each do |b|
        b.update_attributes!(:sort_index => count)
        count = count + 1
      end
    end
    
    # Add :null => false constraint to column
    change_column :blocks, :sort_index, :integer, :null => false
  end
end
