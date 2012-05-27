class AddAssociationsToBlockInputsAndConnections < ActiveRecord::Migration
  
  ### Faux models allowing this migration to save data without running validations.
  ### Prevents issues associated with the current models trying to validate fields
  ### that aren't in the database yet as of this migration.
  ### For more info, see:
  ### http://guides.rubyonrails.org/migrations.html#using-models-in-your-migrations
  class BlockInput < ActiveRecord::Base
    attr_accessible :variable_id
  end
  class BlockConnection < ActiveRecord::Base
    attr_accessible :next_block_id
  end
  
  
  
  def up
    
    ## BlockInputs
    # Change variable:string to variable_id:integer
    remove_column :block_inputs, :variable
    add_column :block_inputs, :variable_id, :integer
    BlockInput.reset_column_information
    BlockInput.all.each do |i|
      i.update_attributes!(:variable_id => 0) # default val for existing objects
    end
    change_column :block_inputs, :variable_id, :integer, :null => false
    
    ## BlockConnections
    # Change next_block:string to next_block_id:integer
    remove_column :block_connections, :next_block
    add_column :block_connections, :next_block_id, :integer
    BlockConnection.reset_column_information
    BlockConnection.all.each do |c|
      c.update_attributes!(:next_block_id => 0) # default val for existing objects
    end
    change_column :block_connections, :next_block_id, :integer, :null => false
    
  end

  def down
    
    remove_column :block_connections, :next_block_id
    add_column :block_connections, :next_block, :string, :null => false, :default => "default"
    remove_column :block_inputs, :variable_id
    add_column :block_inputs, :variable, :string, :null => false, :default => "default"
    
  end
end
