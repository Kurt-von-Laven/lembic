class AddSortIndexToWorkflow < ActiveRecord::Migration
  def change
    Workflow.destroy_all
    add_column :workflows, :sort_index, :integer, :null => false
  end
end
