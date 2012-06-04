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

ActiveRecord::Schema.define(:version => 20120604042146) do

  create_table "block_connections", :force => true do |t|
    t.string   "expression_string", :limit => 1048576, :null => false
    t.integer  "block_id",                             :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.binary   "expression_object",                    :null => false
    t.integer  "sort_index",                           :null => false
    t.integer  "next_block_id",                        :null => false
  end

  create_table "block_variables", :force => true do |t|
    t.integer  "block_id",     :null => false
    t.integer  "sort_index",   :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "variable_id",  :null => false
    t.integer  "display_type"
    t.string   "prompt"
    t.string   "description"
    t.integer  "formatting"
  end

  create_table "blocks", :force => true do |t|
    t.string   "name",         :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "workflow_id",  :null => false
    t.string   "display_type"
    t.integer  "sort_index",   :null => false
  end

  create_table "category_options", :force => true do |t|
    t.integer  "block_variable_id", :null => false
    t.string   "name",              :null => false
    t.string   "value",             :null => false
    t.string   "description"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "index_names", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.integer  "variable_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "model_permissions", :force => true do |t|
    t.integer  "model_id",    :null => false
    t.integer  "user_id",     :null => false
    t.integer  "sort_index",  :null => false
    t.integer  "permissions", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "model_permissions", ["model_id"], :name => "index_model_permissions_on_model_id"
  add_index "model_permissions", ["user_id"], :name => "index_model_permissions_on_user_id"

  create_table "models", :force => true do |t|
    t.string   "name",        :limit => 64, :null => false
    t.string   "description",               :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "run_values", :force => true do |t|
    t.integer  "variable_id",  :null => false
    t.integer  "run_id",       :null => false
    t.string   "index_values"
    t.binary   "value",        :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "runs", :force => true do |t|
    t.integer  "user_id",      :null => false
    t.integer  "workflow_id",  :null => false
    t.integer  "block_id",     :null => false
    t.string   "description"
    t.datetime "completed_at"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       :limit => 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "users", :force => true do |t|
    t.string   "email",        :null => false
    t.string   "first_name",   :null => false
    t.string   "last_name",    :null => false
    t.string   "organization"
    t.string   "pwd_hash",     :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "salt",         :null => false
  end

  create_table "variables", :force => true do |t|
    t.string   "name",              :limit => 64,      :null => false
    t.string   "description",                          :null => false
    t.integer  "workflow_id",                          :null => false
    t.integer  "variable_type",                        :null => false
    t.integer  "array",                                :null => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "expression_string", :limit => 1048576
    t.binary   "expression_object"
  end

  create_table "variables_editors", :force => true do |t|
    t.string   "type"
    t.string   "value"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "workflow_blocks", :force => true do |t|
    t.integer  "workflow_id", :null => false
    t.integer  "block_id",    :null => false
    t.integer  "sort_index",  :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "workflow_permissions", :force => true do |t|
    t.integer  "workflow_id", :null => false
    t.integer  "user_id",     :null => false
    t.integer  "permissions", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "workflows", :force => true do |t|
    t.string   "name",        :limit => 64, :null => false
    t.string   "description",               :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

end
