class CreateRuns < ActiveRecord::Migration
  def change
    create_table :runs do |t|
      t.references :user, :null => false
      t.references :workflow, :null => false
      t.references :block, :null => false
      t.string :description
      t.datetime :completed_at
      t.timestamps
    end
  end
end
