# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120505223110) do

  create_table "permissions", :force => true do |t|
    t.integer  "workflow_id", :null => false
    t.integer  "user_id",     :null => false
    t.integer  "permissions", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "relationships", :force => true do |t|
    t.string "relationship"
  end

  create_table "users", :force => true do |t|
    t.string   "email",        :null => false
    t.string   "first_name",   :null => false
    t.string   "last_name",    :null => false
    t.string   "organization"
    t.string   "pwd_hash",     :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "variables", :force => true do |t|
    t.string   "name",          :limit => 64, :null => false
    t.string   "description",                 :null => false
    t.integer  "workflow_id",                 :null => false
    t.integer  "variable_type",               :null => false
    t.integer  "array",                       :null => false
    t.integer  "const",                       :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "variables_editors", :force => true do |t|
    t.string   "type"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "workflows", :force => true do |t|
    t.string   "name",        :limit => 64, :null => false
    t.string   "description",               :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

end
