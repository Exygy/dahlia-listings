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

ActiveRecord::Schema.define(version: 2019_05_28_070508) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ami_charts", force: :cascade do |t|
    t.string "ami_values_file"
    t.integer "chart_type"
    t.integer "year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id"
    t.index ["chart_type", "year", "group_id"], name: "index_ami_charts_on_chart_type_and_year_and_group_id", unique: true
    t.index ["group_id"], name: "index_ami_charts_on_group_id"
  end

  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.string "domain"
    t.integer "group_type"
    t.integer "parent_id"
    t.integer "lft", null: false
    t.integer "rgt", null: false
    t.integer "depth", default: 0, null: false
    t.integer "children_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gtm_key"
    t.index ["lft"], name: "index_groups_on_lft"
    t.index ["parent_id"], name: "index_groups_on_parent_id"
    t.index ["rgt"], name: "index_groups_on_rgt"
  end

  create_table "listing_images", force: :cascade do |t|
    t.bigint "listing_id"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["listing_id"], name: "index_listing_images_on_listing_id"
  end

  create_table "listings", force: :cascade do |t|
    t.boolean "accepting_applications_at_leasing_agent", default: false, null: false
    t.boolean "accepting_applications_by_po_box", default: false, null: false
    t.boolean "accepting_online_applications", default: false, null: false
    t.string "accessibility"
    t.string "amenities"
    t.datetime "application_due_date"
    t.string "application_organization"
    t.string "application_city"
    t.string "application_phone"
    t.string "application_postal_code"
    t.string "application_state"
    t.string "application_street_address"
    t.boolean "blank_paper_application_can_be_picked_up", default: false, null: false
    t.string "building_city"
    t.string "building_name"
    t.text "building_selection_criteria"
    t.string "building_state"
    t.string "building_street_address"
    t.string "building_url"
    t.string "building_zip_code"
    t.text "costs_not_included"
    t.text "credit_rating"
    t.decimal "deposit_max", precision: 8, scale: 2
    t.decimal "deposit_min", precision: 8, scale: 2
    t.string "developer"
    t.boolean "does_match", default: false, null: false
    t.boolean "first_come_first_served", default: false, null: false
    t.boolean "has_waitlist", default: false, null: false
    t.string "image_url"
    t.boolean "in_lottery", default: false, null: false
    t.datetime "last_modified_date"
    t.text "legal_disclaimers"
    t.string "listing_id"
    t.string "lottery_city"
    t.datetime "lottery_date"
    t.boolean "lottery_results", default: false, null: false
    t.datetime "lottery_results_date"
    t.string "lottery_status"
    t.string "lottery_street_address"
    t.string "lottery_venue"
    t.integer "lottery_winners"
    t.string "lottery_results_url"
    t.string "marketing_url"
    t.integer "maximum_waitlist_size"
    t.string "name"
    t.string "neighborhood"
    t.integer "general_application_total"
    t.integer "number_of_people_currently_on_waitlist"
    t.text "pet_policy"
    t.string "priorities_descriptor"
    t.string "program_type"
    t.string "project_id"
    t.text "required_documents"
    t.integer "reserved_community_maximum_age"
    t.integer "reserved_community_minimum_age"
    t.string "reserved_descriptor"
    t.boolean "sase_required_for_lottery_ticket", default: false, null: false
    t.text "smoking_policy"
    t.integer "total_waitlist_openings"
    t.integer "units_available"
    t.integer "year_built"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "group_id"
    t.boolean "show_unit_features"
    t.text "unit_amenities"
    t.index ["group_id"], name: "index_listings_on_group_id"
  end

  create_table "units", force: :cascade do |t|
    t.decimal "ami_percentage", precision: 5, scale: 2
    t.decimal "bmr_annual_income_min", precision: 8, scale: 2
    t.decimal "bmr_monthly_income_min", precision: 8, scale: 2
    t.decimal "max_household_income", precision: 8, scale: 2
    t.integer "max_occupancy"
    t.integer "min_occupancy"
    t.decimal "monthly_rent", precision: 8, scale: 2
    t.integer "num_bathrooms"
    t.integer "num_bedrooms"
    t.integer "priority_type"
    t.integer "reserved_type"
    t.integer "status"
    t.integer "floor"
    t.string "number"
    t.integer "sq_ft"
    t.integer "unit_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "listing_id"
    t.bigint "ami_chart_id"
    t.index ["ami_chart_id"], name: "index_units_on_ami_chart_id"
    t.index ["listing_id"], name: "index_units_on_listing_id"
  end

  add_foreign_key "ami_charts", "groups"
  add_foreign_key "listings", "groups"
  add_foreign_key "units", "ami_charts"
  add_foreign_key "units", "listings"
end
