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

ActiveRecord::Schema.define(version: 2021_12_06_194634) do

  create_table "areas", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.integer "position"
    t.boolean "tombstone", default: false, null: false
    t.bigint "inspection_id", null: false
    t.string "uuid", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["inspection_id"], name: "index_areas_on_inspection_id"
    t.index ["uuid"], name: "index_areas_on_uuid", unique: true
  end

  create_table "areas_timestamps", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "position"
    t.bigint "area_id", null: false
    t.index ["area_id"], name: "index_areas_timestamps_on_area_id", unique: true
  end

  create_table "inspections", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "tombstone", default: false, null: false
    t.string "uuid", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "note"
    t.datetime "deleted_at"
    t.index ["uuid"], name: "index_inspections_on_uuid", unique: true
  end

  create_table "inspections_timestamps", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.bigint "inspection_id", null: false
    t.string "note"
    t.index ["inspection_id"], name: "index_inspections_timestamps_on_inspection_id", unique: true
  end

  create_table "items", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.text "note"
    t.boolean "flagged", default: false, null: false
    t.boolean "tombstone", default: false, null: false
    t.bigint "area_id", null: false
    t.string "uuid", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.datetime "deleted_at"
    t.index ["area_id"], name: "index_items_on_area_id"
    t.index ["uuid"], name: "index_items_on_uuid", unique: true
  end

  create_table "items_timestamps", charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "note"
    t.string "flagged"
    t.bigint "item_id", null: false
    t.index ["item_id"], name: "index_items_timestamps_on_item_id", unique: true
  end

  add_foreign_key "areas", "inspections"
  add_foreign_key "areas_timestamps", "areas"
  add_foreign_key "inspections_timestamps", "inspections"
  add_foreign_key "items", "areas"
  add_foreign_key "items_timestamps", "items"
end
