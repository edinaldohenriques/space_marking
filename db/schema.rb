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

ActiveRecord::Schema[7.1].define(version: 2024_12_07_130118) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "reservations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0
    t.uuid "user_id", null: false
    t.uuid "space_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "shifts", default: [], array: true
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.text "booking_information", null: false
    t.text "description"
    t.text "justification"
    t.index ["space_id"], name: "index_reservations_on_space_id"
    t.index ["user_id"], name: "index_reservations_on_user_id"
  end

  create_table "spaces", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "location", null: false
    t.integer "capacity", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "board", default: false
    t.boolean "laboratory", default: false
    t.boolean "projector", default: false
    t.boolean "accessibility", default: false
    t.boolean "active", default: true
    t.integer "floor", default: 0
    t.boolean "occupied", default: false
    t.text "disabled_reason"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "name", null: false
    t.integer "user_type", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "student_id_number", null: false
    t.string "phone_number", null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "reservations", "spaces"
  add_foreign_key "reservations", "users"
end
