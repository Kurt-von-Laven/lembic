class ChangeIndexNamesRenamePositionToSortIndex < ActiveRecord::Migration
  def change
    rename_column :index_names, :position, :sort_index
  end
end
