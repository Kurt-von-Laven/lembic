class MakeBlocksNonNull < ActiveRecord::Migration
  def up
    BlockConnection.delete_all
    BlockInput.delete_all
    Block.delete_all
    change_column :blocks, :name, :string, :null => false
    change_column :block_connections, :block_id, :integer, :null => false
    change_column :block_connections, :expression, :string, :null => false
    change_column :block_inputs, :block_id, :integer, :null => false
    change_column :block_inputs, :sort_index, :integer, :null => false
    change_column :block_inputs, :variable, :string, :null => false
  end
  
  def down
    change_column :blocks, :name, :string, :null => true
    change_column :block_connections, :block_id, :integer, :null => true
    change_column :block_connections, :expression, :string, :null => true
    change_column :block_inputs, :block_id, :integer, :null => true
    change_column :block_inputs, :sort_index, :integer, :null => true
    change_column :block_inputs, :variable, :string, :null => true
  end
end
