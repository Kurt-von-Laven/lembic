class DeleteAllBlocks < ActiveRecord::Migration
  def up
    Block.delete_all
    BlockInput.delete_all
    BlockConnection.delete_all
  end

  def down
  end
end
