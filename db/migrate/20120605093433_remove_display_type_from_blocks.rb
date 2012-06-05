class RemoveDisplayTypeFromBlocks < ActiveRecord::Migration
  def change
    remove_column :blocks, :display_type
  end
end
