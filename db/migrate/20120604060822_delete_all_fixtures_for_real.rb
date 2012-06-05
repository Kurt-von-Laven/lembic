class DeleteAllFixturesForReal < ActiveRecord::Migration
  def up
    WorkflowPermission.delete_all
    ModelPermission.delete_all
    Workflow.delete_all
    Model.delete_all
  end

  def down
    raise ActiveRecord::IrreversibleMigration, 'Can\'t undo record deletions.'
  end
end
