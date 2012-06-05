class CreateDefaultModelAndWorkflow < ActiveRecord::Migration
  def change
    drop_table :workflow_blocks
  end
end
