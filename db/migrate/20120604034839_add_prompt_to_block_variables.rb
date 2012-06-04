class AddPromptToBlockVariables < ActiveRecord::Migration
  def change
    add_column :block_variables, :prompt, :string
  end
end
