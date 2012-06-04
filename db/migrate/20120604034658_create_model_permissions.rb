class CreateModelPermissions < ActiveRecord::Migration
  def change
    create_table :model_permissions do |t|
      t.references :model, :null => false
      t.references :user, :null => false
      t.integer :sort_index, :null => false
      t.integer :permissions, :null => false

      t.timestamps
    end
    add_index :model_permissions, :model_id
    add_index :model_permissions, :user_id
  end
end
