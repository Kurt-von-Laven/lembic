class CreateCategoryOptions < ActiveRecord::Migration
  def change
    create_table :category_options do |t|
      t.references :block_variable, :null => false
      t.string :name, :null => false #user-facing name
      t.string :value, :null => false #system-facing symbol
      t.string :description
      t.timestamps
    end
  end
end
