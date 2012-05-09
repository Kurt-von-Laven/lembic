class EpxressionNullTrue < ActiveRecord::Migration
  def change
	change_column :variables, :expression_string, :string, :null => true
	change_column :variables, :expression_object, :binary, :null => true
  end
end
