class RenamePermissionsToWorkflowPermissions < ActiveRecord::Migration
  def up
    rename_table :permissions, :workflow_permissions
  end

  def down
    rename_table :workflow_permissions, :permissions
  end
end
