# frozen_string_literal: true

# Listing data operations
class ListingService
  require 'csv'

  def self.create_unit_summaries(listing = nil)
    return false unless listing

    units = listing.units
    return false unless units

    unit_summaries = {
      general: [],
      reserved: [],
    }

    units.each do |unit|
      unit_summaries[:general] <<
        {
          listing_id: listing.id,
          max_occupancy: 2,
          maxMonthlyRent: 1900,
          maxPercentIncome: nil,
          maxRentalMinIncome: 3800,
          maxSquareFt: 559,
          min_occupancy: 1,
          minMonthlyRent: 1900,
          minPercentIncome: nil,
          minRentalMinIncome: 3800,
          minSquareFt: 559,
          priorities: nil,
          totalUnits: 1,
          unitType: I18n.t("unit_types.#{unit['unit_type']}"),
        }
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
