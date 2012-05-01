class CreateVariablesEditors < ActiveRecord::Migration
  def change
    create_table :variables_editors do |t|
      t.string :type
      t.string :value

      t.timestamps
    end
  end
end
