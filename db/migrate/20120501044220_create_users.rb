class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email, :null => false
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.string :organization
      t.string :pwd_hash, :null => false
      t.timestamps :null => false
    end
  end
end
