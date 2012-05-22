class CreateBlockConnections < ActiveRecord::Migration
  def change
    create_table :block_connections do |t|
      t.string :expression # Use this connection if expression evals to true
      t.string :next_block # Block to go to if using this connection
      t.integer :block_id  # Block that this connection starts from

      t.timestamps
    end
  end
end
