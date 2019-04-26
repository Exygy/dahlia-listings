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

ActiveRecord::Schema.define(version: 2019_04_26_230445) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
  end

  create_table "uploaded_files", id: :serial, force: :cascade do |t|
    t.binary "file"
    t.string "name"
    t.string "content_type"
    t.string "session_uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "listing_id"
    t.string "document_type"
    t.integer "user_id"
    t.string "address"
    t.integer "rent_burden_type"
    t.string "rent_burden_index"
    t.string "listing_preference_id"
    t.string "application_id"
    t.datetime "delivered_at"
    t.string "error"
    t.index ["rent_burden_type", "rent_burden_index", "address"], name: "rent_burden_idx"
    t.index ["session_uid"], name: "index_uploaded_files_on_session_uid"
    t.index ["user_id"], name: "index_uploaded_files_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "salesforce_contact_id"
    t.string "temp_session_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["temp_session_id"], name: "index_users_on_temp_session_id"
    t.index ["uid", "provider"], name: "index_users_on_uid_and_provider", unique: true
  end

end
