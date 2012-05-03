class AddMinimumViableVariableColumns < ActiveRecord::Migration
  def up
    drop_table :variables
    create_table :variables do |t|
      t.string :name, :limit => 64, :null => false
      t.string :description, :null => false
      t.integer :workflow_id, :null => false
      t.integer :variable_type, :null => false
      t.integer :array, :null => false
      t.integer :const, :null => false
      t.timestamps :null => false
    end
  end

  def down
    drop_table :variables
    create_table :variables do |t|
      t.string :name
      t.string :value
      t.timestamps
    end
  end
  
end
