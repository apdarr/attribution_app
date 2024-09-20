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

ActiveRecord::Schema[7.0].define(version: 2024_09_17_150546) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "billing_months", force: :cascade do |t|
    t.bigint "business_unit_id", null: false
    t.string "billing_month"
    t.decimal "total_cost", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["billing_month", "business_unit_id"], name: "index_billing_months_on_billing_month_and_business_unit_id", unique: true
    t.index ["business_unit_id"], name: "index_billing_months_on_business_unit_id"
  end

  create_table "business_units", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "repos", default: [], array: true
    t.string "prefix"
  end

  create_table "polling_statuses", force: :cascade do |t|
    t.string "usage_worker_checked_identifier"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "repo_costs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "cost", precision: 10, scale: 2
    t.string "repo_name"
    t.bigint "billing_month_id"
    t.bigint "repo_id"
    t.string "sku"
    t.index ["repo_id"], name: "index_repo_costs_on_repo_id"
  end

  create_table "repos", force: :cascade do |t|
    t.string "name"
    t.string "property"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "business_unit_id"
    t.string "org"
    t.index ["org", "name"], name: "index_repos_on_org_and_name", unique: true
  end

  add_foreign_key "billing_months", "business_units"
  add_foreign_key "repo_costs", "repos"
  add_foreign_key "repos", "business_units"
end