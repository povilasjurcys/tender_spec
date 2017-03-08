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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 0) do

  create_table "tender_spec_app_files", force: :cascade do |t|
    t.string "path"
  end

  add_index "tender_spec_app_files", ["path"], name: "index_tender_spec_app_files_on_path"

  create_table "tender_spec_app_tests", force: :cascade do |t|
    t.text "description"
  end

  add_index "tender_spec_app_tests", ["description"], name: "index_tender_spec_app_tests_on_description"

  create_table "tender_spec_line_tests", force: :cascade do |t|
    t.integer "app_file_id"
    t.integer "app_test_id"
    t.integer "line_no"
  end

  add_index "tender_spec_line_tests", ["app_test_id", "app_file_id", "line_no", nil], name: "line_uniqueness_idx"

end
