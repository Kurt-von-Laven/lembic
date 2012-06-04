class ChangeVariablesRenameWorkflowToModel < ActiveRecord::Migration
  def change
    rename_column :variables, :workflow_id, :model_id
  end
end
