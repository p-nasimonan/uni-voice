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

ActiveRecord::Schema[8.0].define(version: 2025_07_01_022555) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "attachments", force: :cascade do |t|
    t.bigint "comment_id", null: false
    t.string "filename", null: false
    t.bigint "file_size"
    t.string "content_type"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["comment_id"], name: "index_attachments_on_comment_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "syllabus_id", null: false
    t.bigint "user_id", null: false
    t.bigint "parent_id"
    t.text "content"
    t.integer "comment_type", default: 0, null: false
    t.integer "rating"
    t.boolean "is_anonymous", default: false
    t.json "metadata"
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["syllabus_id", "comment_type"], name: "index_comments_on_syllabus_id_and_comment_type"
    t.index ["syllabus_id", "created_at"], name: "index_comments_on_syllabus_id_and_created_at"
    t.index ["syllabus_id"], name: "index_comments_on_syllabus_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "syllabuses", force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "university"
    t.string "professor"
    t.integer "year"
    t.string "semester"
    t.integer "credits"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "university_id", null: false
    t.string "url"
    t.string "course_number"
    t.string "faculty_department"
    t.string "day_period"
    t.index ["university_id"], name: "index_syllabuses_on_university_id"
  end

  create_table "universities", force: :cascade do |t|
    t.string "name"
    t.string "location"
    t.string "website"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email_domain", null: false
    t.index ["email_domain"], name: "index_universities_on_email_domain", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "name", default: "ななし", null: false
    t.string "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["user_id"], name: "index_users_on_user_id", unique: true
  end

  add_foreign_key "attachments", "comments"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "syllabuses"
  add_foreign_key "comments", "users"
  add_foreign_key "syllabuses", "universities"
end
