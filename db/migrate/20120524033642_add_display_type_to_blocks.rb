class AddDisplayTypeToBlocks < ActiveRecord::Migration
  def change
    add_column :blocks, :display_type, :string
  end
end
