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

ActiveRecord::Schema[8.0].define(version: 2025_06_12_115607) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "syllabuses", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "university"
    t.string "faculty"
    t.string "department"
    t.string "course_name"
    t.string "professor"
    t.integer "year"
    t.string "semester"
    t.integer "credits"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "university_id", null: false
    t.index ["university_id"], name: "index_syllabuses_on_university_id"
  end

  create_table "universities", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.string "website"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "syllabuses", "universities"
end
