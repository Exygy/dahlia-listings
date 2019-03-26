class CreateListings < ActiveRecord::Migration
  def change
    create_table :listings do |t|
      t.boolean :accepting_applications_at_leasing_agent, null: false, default: false
      t.boolean :accepting_applications_by_po_box, null: false, default: false
      t.boolean :accepting_online_applications, null: false, default: false
      t.string :accessibility
      t.string :amenities
      t.datetime :application_due_date
      t.string :application_organization
      t.string :application_city
      t.string :application_phone
      t.string :application_postal_code
      t.string :application_state
      t.string :application_street_address
      t.boolean :blank_paper_application_can_be_picked_up, null: false, default: false
      t.string :building_city
      t.string :building_name
      t.text :building_selection_criteria
      t.string :building_state
      t.string :building_street_address
      t.string :building_url
      t.string :building_zip_code
      t.text :costs_not_included
      t.text :credit_rating
      t.decimal :deposit_max, precision: 8, scale: 2
      t.decimal :deposit_min, precision: 8, scale: 2
      t.string :developer
      t.boolean :does_match, null: false, default: false
      t.boolean :first_come_first_served, null: false, default: false
      t.boolean :has_waitlist, null: false, default: false
      t.string :image_url
      t.boolean :in_lottery, null: false, default: false
      t.datetime :last_modified_date
      t.text :legal_disclaimers
      t.string :listing_id
      t.string :lottery_city
      t.datetime :lottery_date
      t.boolean :lottery_results, null: false, default: false
      t.datetime :lottery_results_date
      t.string :lottery_status
      t.string :lottery_street_address
      t.string :lottery_venue
      t.integer :lottery_winners
      t.string :lottery_results_url
      t.string :marketing_url
      t.integer :maximum_waitlist_size
      t.string :name
      t.string :neighborhood
      t.integer :general_application_total
      t.integer :number_of_people_currently_on_waitlist
      t.text :pet_policy
      t.string :priorities_descriptor
      t.string :program_type
      t.string :project_id
      t.text :required_documents
      t.integer :reserved_community_maximum_age
      t.integer :reserved_community_minimum_age
      t.string :reserved_descriptor
      t.boolean :sase_required_for_lottery_ticket, null: false, default: false
      t.text :smoking_policy
      t.integer :total_waitlist_openings
      t.integer :units_available
      t.integer :year_built

      t.timestamps null: false
    end
  end
end
