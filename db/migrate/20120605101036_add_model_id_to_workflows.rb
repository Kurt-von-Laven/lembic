class AddModelIdToWorkflows < ActiveRecord::Migration
  def change
    add_column :workflows, :model_id, :integer, :null => false, :default => 1
  end
end
