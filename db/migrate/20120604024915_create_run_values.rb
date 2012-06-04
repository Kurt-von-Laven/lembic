class CreateRunValues < ActiveRecord::Migration
  def change
    create_table :run_values do |t|
      t.primary_key :id, :null => false
      t.integer :variable_id, :null => false
      t.integer :run_id, :null => false
      t.string :index_values
      t.binary :value, :null => false
      t.timestamps :null => false
    end
  end
end
