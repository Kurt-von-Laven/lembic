class EditVariablesExpressions < ActiveRecord::Migration
  def change
	add_column :variables, :expression_string, :string, :null => false
	add_column :variables, :expression_object, :binary, :null => false
	remove_column :variables, :const
  end
end
