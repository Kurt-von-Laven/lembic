class CreateModels < ActiveRecord::Migration
  def change
    create_table :models do |t|
      t.string :name, :limit => 64, :null => false
      t.string :description, :null => false

      t.timestamps
    end
  end
end
