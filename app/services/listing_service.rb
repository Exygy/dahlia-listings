# frozen_string_literal: true

# Listing data operations
class ListingService
  require 'csv'

  # A listing can have many units, and may have multiple units of the same unit
  # type, e.g. 10 studio units, 10 1BR units, and 10 2BR units. Not all units
  # of the same unit type will have the same rents or same income requirements.
  # A listing could have one studio unit that has a rent of $1400 and another
  # studio unit that has a rent of $1500. When we display the listing's units
  # grouped by unit type, we need to express the range of rents, minimum income
  # requirements, and other data that may be present in that group of that unit type.
  # create_unit_summaries goes over all of a listing's units and puts together,
  # for each unit type present on the listing, a summary of the range of details
  # across the units in each unit type.
  def self.create_unit_summaries(listing)
    units = listing.units
    return {} unless units

    general_units = []
    reserved_units = []

    units.each do |u|
      u.reserved_type ? reserved_units << u : general_units << u
    end

    unit_summaries = {}

    { general: general_units, reserved: reserved_units }.each do |group_name, group_units|
      units_by_type = group_units.group_by(&:unit_type)
      summaries = units_by_type.map do |unit_type, unit_type_group|
        UnitService.unit_type_group_summary(unit_type, unit_type_group)
      end
      unit_summaries[group_name] = summaries if summaries.present?
    end

    unit_summaries
  end

  def self.create_ami_chart_summaries(listing)
    units_with_ami_charts = listing&.units&.select { |u| u.ami_chart }
    units_with_ami_charts&.map do |unit|
      {
        chart_id: unit.ami_chart.id,
        percent: unit.ami_percentage,
      }
    end
  end

  # FIXME: get_ami_chart_values_for_percent should be a method on the AMI chart model
  def self.get_ami_chart_values_for_percent(id, percent)
    chart = AmiChart.find(id)
    all_ami_values = CSV.read(chart.ami_values_file, headers: true, converters: :integer)

    values_for_percent = all_ami_values.select do |row|
      row['percent_of_ami'] == percent
    end

    formatted_values = values_for_percent.map do |value|
      {
        amount: value['income'],
        numOfHousehold: value['household_size'],
      }
    end

    formatted_values.sort_by { |i| i[:numOfHousehold] }
  end
end
