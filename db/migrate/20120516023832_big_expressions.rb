class BigExpressions < ActiveRecord::Migration
  def change
    change_column :variables, :expression_string, :string, :null => true, :limit => 1.megabyte
  end
end
