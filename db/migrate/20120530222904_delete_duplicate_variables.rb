require "./app/models/variable"

class DeleteDuplicateVariables < ActiveRecord::Migration
  def change
    Variable.delete_all("name LIKE '%[%'")
  end
end
