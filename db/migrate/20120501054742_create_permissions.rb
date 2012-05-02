class CreatePermissions < ActiveRecord::Migration
  def change
    create_table :permissions do |t|
      t.integer :workflow_id, :null => false
      t.integer :user_id, :null => false
      t.integer :permissions, :null => false
      t.timestamps :null => false
    end
  end
end
