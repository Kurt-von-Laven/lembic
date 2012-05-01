class CreateWorkflows < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.string :name, :limit => 64, :null => false
      t.string :description, :null => false
      
      t.timestamps :null => false
    end
  end
end
