class AddWorkflowIdToBlock < ActiveRecord::Migration
  def change
    Block.delete_all
    add_column :blocks, :workflow_id, :integer, :null => false
  end
end
