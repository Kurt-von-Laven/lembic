class SplitExpressionIntoStringAndObject < ActiveRecord::Migration
  def change
    rename_column :block_connections, :expression, :expression_string
    change_column :block_connections, :expression_string, :string, :null => false, :limit => 1.megabyte
    add_column :block_connections, :expression_object, :binary, :null => false
  end
end
