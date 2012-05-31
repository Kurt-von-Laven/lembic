class DestroyAllBlocks < ActiveRecord::Migration
  def up
    # Should also destroy all block_inputs and block_connections due to :dependent => :destroy
    Block.destroy_all
  end

  def down
  end
end
