class CreateBlockInputs < ActiveRecord::Migration
  def change
    create_table :block_inputs do |t|
      t.integer :block_id
      t.string :variable
      t.integer :sort_index

      t.timestamps
    end
  end
end
