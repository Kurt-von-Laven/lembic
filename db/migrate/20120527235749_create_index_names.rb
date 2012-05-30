require "index_name.rb"
require "variable.rb"

class CreateIndexNames < ActiveRecord::Migration
  def up
    create_table :index_names do |t|
      t.string :name
      t.integer :position
      t.integer :variable_id
      t.timestamps
    end
    
    Variable.find(:all).each do |v|
      index_list = v.name.split(/\s*\[\s*|\s*\]\s*/)[1]
      indices = nil
      if index_list
        indices = index_list.split(/\s*,\s*/)
      end
      if indices
        puts "migrating indices: #{indices.inspect}"
        indices.each_with_index do |index, i|
          puts "   #{index}, #{i}"
          new_index_name = IndexName.new({:name => index, :position => i, :variable_id => v.id})
          new_index_name.save
        end
      end
    end
    
    Variable.reset_column_information
  end
  
  def down
    drop_table :index_names
    Variable.reset_column_information
  end
end
