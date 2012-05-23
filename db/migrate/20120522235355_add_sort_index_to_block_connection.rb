class AddSortIndexToBlockConnection < ActiveRecord::Migration
  def change
    BlockConnection.delete_all
    add_column :block_connections, :sort_index, :integer, :null => false
  end
end
