class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.string relationship
    end
  end
end
