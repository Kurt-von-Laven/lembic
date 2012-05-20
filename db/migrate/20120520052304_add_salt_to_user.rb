class AddSaltToUser < ActiveRecord::Migration
  def change
    User.delete_all
    ActiveRecord::Base.connection.execute "ALTER SEQUENCE users_id_seq RESTART WITH 1;"
    add_column :users, :salt, :string, :null => false
  end
end
