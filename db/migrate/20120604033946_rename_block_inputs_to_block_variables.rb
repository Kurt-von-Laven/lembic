class RenameBlockInputsToBlockVariables < ActiveRecord::Migration
  def up
    rename_table :block_inputs, :block_variables
  end

  def down
    rename_table :block_variables, :block_inputs
  end
end
