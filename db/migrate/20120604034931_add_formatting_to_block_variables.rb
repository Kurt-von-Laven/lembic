class AddFormattingToBlockVariables < ActiveRecord::Migration
  def change
    add_column :block_variables, :formatting, :integer
  end
end
