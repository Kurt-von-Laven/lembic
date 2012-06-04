class CreateWorkflowBlocks < ActiveRecord::Migration
  def change
    create_table :workflow_blocks do |t|
      t.references :workflow, :null => false
      t.references :block, :null => false
      t.integer :sort_index, :null => false
      t.timestamps
    end
  end
end
