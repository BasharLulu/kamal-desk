# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_06_065900) do
  create_table "deployment_runs", force: :cascade do |t|
    t.string "command", null: false
    t.datetime "created_at", null: false
    t.string "destination"
    t.integer "exit_code"
    t.datetime "finished_at"
    t.text "output"
    t.integer "project_id", null: false
    t.datetime "started_at"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.string "version"
    t.index ["project_id"], name: "index_deployment_runs_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "config_path"
    t.datetime "created_at", null: false
    t.json "destinations"
    t.datetime "last_synced_at"
    t.string "name"
    t.string "root_path"
    t.datetime "updated_at", null: false
    t.index ["root_path"], name: "index_projects_on_root_path", unique: true
  end

  add_foreign_key "deployment_runs", "projects"
end
