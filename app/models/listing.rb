# frozen_string_literal: true

# TODO: Re-enable Rubocop's line length check on this file once
# we have settled on a format for the field mapping items
# rubocop:disable Metrics/LineLength

# Represent a listing object. Provide mapping between Salesforce
# object field names, Salesforce custom API field names, and
# domain field names for listings.
class Listing < ActiveRecord::Base
  include ObjectBase

  # TODO: Once we add more models and more fields, consider moving the
  # field mappings into YML files or other places.
  FIELD_NAME_MAPPINGS = [
    { custom_api: 'Accepting_applications_at_leasing_agent', domain: 'accepting_applications_at_leasing_agent', salesforce: 'Accepting_applications_at_leasing_agent' },
    { custom_api: 'Accepting_applications_by_PO_Box', domain: 'accepting_applications_by_po_box', salesforce: 'Accepting_applications_by_PO_Box' },
    { custom_api: 'Accepting_Online_Applications', domain: 'accepting_online_applications', salesforce: 'Accepting_Online_Applications' },
    { custom_api: 'Accessibility', domain: 'accessibility', salesforce: 'Accessibility' },
    { custom_api: 'Amenities', domain: 'amenities', salesforce: 'Amenities' },
    { custom_api: 'Application_Due_Date', domain: 'application_due_date', salesforce: 'Application_Due_Date' },
    { custom_api: 'Application_Organization', domain: 'application_organization', salesforce: 'Application_Organization' },
    { custom_api: 'Application_City', domain: 'application_city', salesforce: 'Application_City' },
    { custom_api: 'Application_Phone', domain: 'application_phone', salesforce: 'Application_Phone' },
    { custom_api: 'Application_Postal_Code', domain: 'application_postal_code', salesforce: 'Application_Postal_Code' },
    { custom_api: 'Application_State', domain: 'application_state', salesforce: 'Application_State' },
    { custom_api: 'Application_Street_Address', domain: 'application_street_address', salesforce: 'Application_Street_Address' },
    { custom_api: 'Blank_paper_application_can_be_picked_up', domain: 'blank_paper_application_can_be_picked_up', salesforce: 'Blank_paper_application_can_be_picked_up' },
    { custom_api: 'Building_City', domain: 'building_city', salesforce: 'Building_City' },
    { custom_api: 'Building_Name', domain: 'building_name', salesforce: 'Building_Name' },
    { custom_api: 'Building_Selection_Criteria', domain: 'building_selection_criteria', salesforce: 'Building_Selection_Criteria' },
    { custom_api: 'Building_State', domain: 'building_state', salesforce: 'Building_State' },
    { custom_api: 'Building_Street_Address', domain: 'building_street_address', salesforce: 'Building_Street_Address' },
    { custom_api: 'Building_URL', domain: 'building_url', salesforce: 'Building_URL' },
    { custom_api: 'Building_Zip_Code', domain: 'building_zip_code', salesforce: 'Building_Zip_Code' },
    { custom_api: 'Costs_Not_Included', domain: 'costs_not_included', salesforce: 'Costs_Not_Included' },
    { custom_api: 'Credit_Rating', domain: 'credit_rating', salesforce: 'Credit_Rating' },
    { custom_api: 'Deposit_Max', domain: 'deposit_max', salesforce: 'Deposit_Max' },
    { custom_api: 'Deposit_Min', domain: 'deposit_min', salesforce: 'Deposit_Min' },
    { custom_api: 'Developer', domain: 'developer', salesforce: 'Developer' },
    { custom_api: 'doesMatch', domain: 'does_match', salesforce: 'doesMatch' },
    { custom_api: 'First_Come_First_Served', domain: 'first_come_first_served', salesforce: 'First_Come_First_Served' },
    { custom_api: 'hasWaitlist', domain: 'has_waitlist', salesforce: 'hasWaitlist' },
    { custom_api: 'Id', domain: 'id', salesforce: 'Id' },
    { custom_api: 'imageURL', domain: 'image_url', salesforce: 'imageURL' },
    { custom_api: 'In_Lottery', domain: 'in_lottery', salesforce: 'In_Lottery' },
    { custom_api: 'LastModifiedDate', domain: 'last_modified_date', salesforce: 'LastModifiedDate' },
    { custom_api: 'Legal_Disclaimers', domain: 'legal_disclaimers', salesforce: 'Legal_Disclaimers' },
    { custom_api: 'listingID', domain: 'listing_id', salesforce: 'listingID' },
    { custom_api: 'Lottery_City', domain: 'lottery_city', salesforce: 'Lottery_City' },
    { custom_api: 'Lottery_Date', domain: 'lottery_date', salesforce: 'Lottery_Date' },
    { custom_api: 'Lottery_Results', domain: 'lottery_results', salesforce: 'Lottery_Results' },
    { custom_api: 'Lottery_Results_Date', domain: 'lottery_results_date', salesforce: 'Lottery_Results_Date' },
    { custom_api: 'Lottery_Status', domain: 'lottery_status', salesforce: 'Lottery_Status' },
    { custom_api: 'Lottery_Street_Address', domain: 'lottery_street_address', salesforce: 'Lottery_Street_Address' },
    { custom_api: 'Lottery_Venue', domain: 'lottery_venue', salesforce: 'Lottery_Venue' },
    { custom_api: 'Lottery_Winners', domain: 'lottery_winners', salesforce: 'Lottery_Winners' },
    { custom_api: 'LotteryResultsURL', domain: 'lottery_results_url', salesforce: 'LotteryResultsURL' },
    { custom_api: 'Marketing_URL', domain: 'marketing_url', salesforce: 'Marketing_URL' },
    { custom_api: 'Maximum_waitlist_size', domain: 'maximum_waitlist_size', salesforce: 'Maximum_waitlist_size' },
    { custom_api: 'Name', domain: 'name', salesforce: 'Name' },
    { custom_api: 'Neighborhood', domain: 'neighborhood', salesforce: 'Neighborhood' },
    { custom_api: 'nGeneral_Application_Total', domain: 'general_application_total', salesforce: 'nGeneral_Application_Total' },
    { custom_api: 'Number_of_people_currently_on_waitlist', domain: 'number_of_people_currently_on_waitlist', salesforce: 'Number_of_people_currently_on_waitlist' },
    { custom_api: 'Pet_Policy', domain: 'pet_policy', salesforce: 'Pet_Policy' },
    { custom_api: 'prioritiesDescriptor', domain: 'priorities_descriptor', salesforce: 'prioritiesDescriptor' },
    { custom_api: 'Program_Type', domain: 'program_type', salesforce: 'Program_Type' },
    { custom_api: 'Project_ID', domain: 'project_id', salesforce: 'Project_ID' },
    { custom_api: 'Required_Documents', domain: 'required_documents', salesforce: 'Required_Documents' },
    { custom_api: 'Reserved_community_maximum_age', domain: 'reserved_community_maximum_age', salesforce: 'Reserved_community_maximum_age' },
    { custom_api: 'Reserved_community_minimum_age', domain: 'reserved_community_minimum_age', salesforce: 'Reserved_community_minimum_age' },
    { custom_api: 'reservedDescriptor', domain: 'reserved_descriptor', salesforce: 'reservedDescriptor' },
    { custom_api: 'SASE_Required_for_Lottery_Ticket', domain: 'sase_required_for_lottery_ticket', salesforce: 'SASE_Required_for_Lottery_Ticket' },
    { custom_api: 'Smoking_Policy', domain: 'smoking_policy', salesforce: 'Smoking_Policy' },
    { custom_api: 'Total_waitlist_openings', domain: 'total_waitlist_openings', salesforce: 'Total_waitlist_openings' },
    { custom_api: 'Units_Available', domain: 'units_available', salesforce: 'Units_Available' },
    { custom_api: 'Year_Built', domain: 'year_built', salesforce: 'Year_Built' },
    # object fields
    { custom_api: 'attributes', domain: 'attributes', salesforce: 'attributes' },
    { custom_api: 'Building', domain: 'building', salesforce: 'Building' },
    { custom_api: 'chartTypes', domain: 'chart_types', salesforce: 'chartTypes' },
    { custom_api: 'Listing_Lottery_Preferences', domain: 'listing_lottery_preferences', salesforce: 'Listing_Lottery_Preferences' },
    { custom_api: 'Open_Houses', domain: 'open_houses', salesforce: 'Open_Houses' },
    { custom_api: 'Units', domain: 'units', salesforce: 'Units' },
    { custom_api: 'unitSummaries', domain: 'unit_summaries', salesforce: 'unitSummaries' },
  ].freeze

  def object_fields
    [
      { custom_api: 'attributes', domain: 'attributes', salesforce: 'attributes' },
      { custom_api: 'Building', domain: 'building', salesforce: 'Building' },
      { custom_api: 'chartTypes', domain: 'chart_types', salesforce: 'chartTypes' },
      { custom_api: 'Listing_Lottery_Preferences', domain: 'listing_lottery_preferences', salesforce: 'Listing_Lottery_Preferences' },
      { custom_api: 'Open_Houses', domain: 'open_houses', salesforce: 'Open_Houses' },
      { custom_api: 'Units', domain: 'units', salesforce: 'Units' },
      { custom_api: 'unitSummaries', domain: 'unit_summaries', salesforce: 'unitSummaries' },
    ]
  end

  def to_domain
    domain_fields = super

    # Special field conversion cases for listings:
    # Remove any fields that are objects
    object_fields.each do |field_map|
      domain_fields.delete(field_map[:domain])
    end

    domain_fields
  end

  def to_salesforce_from_db
    salesforce_fields = {}

    self.class::FIELD_NAME_MAPPINGS.each do |field_map|
      salesforce_field_name = field_map[:salesforce]
      # Add blank hashes for any fields that are objects
      if object_fields.any? { |f| f[:salesforce] == salesforce_field_name }
        salesforce_fields[salesforce_field_name] = {}
      else
        salesforce_fields[salesforce_field_name] = send(field_map[:domain])
      end
    end

    salesforce_fields
  end
end

# rubocop:enable Metrics/LineLength
