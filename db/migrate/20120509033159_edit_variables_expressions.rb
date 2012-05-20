class EditVariablesExpressions < ActiveRecord::Migration
  def change
    Variable.delete_all
    add_column :variables, :expression_string, :string, :null => false
    add_column :variables, :expression_object, :binary, :null => false
    remove_column :variables, :const
  end
end
