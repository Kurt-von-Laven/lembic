class AddSortIndexToWorkflow < ActiveRecord::Migration
  def change
    Workflow.delete_all
    Block.destroy_all
    add_column :workflows, :sort_index, :integer, :null => false
  end
end
