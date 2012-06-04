class AddDescriptionToBlockVariables < ActiveRecord::Migration
  def change
    add_column :block_variables, :description, :string
  end
end
