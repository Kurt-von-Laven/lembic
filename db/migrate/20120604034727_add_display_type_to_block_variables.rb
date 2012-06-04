class AddDisplayTypeToBlockVariables < ActiveRecord::Migration
  def change
    add_column :block_variables, :display_type, :integer
  end
end
