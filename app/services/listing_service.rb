# frozen_string_literal: true

# Listing data operations
class ListingService
  require 'csv'

  def self.create_unit_summaries(listing = nil)
    return false unless listing

    units = listing.units
    return false unless units

    # FIXME: Implement actual logic to go over all units of a listing and
    # create a summary. Unit summary is hardcoded here to work with demo data.
    {
      reserved: nil,
      general: [
        {
          unitType: 'Studio',
          totalUnits: 1,
          priorities: nil,
          minSquareFt: 559,
          minRentalMinIncome: 3800,
          minPriceWithParking: nil,
          minPriceWithoutParking: nil,
          minPercentIncome: nil,
          min_occupancy: 1,
          minMonthlyRent: 1900,
          minHoaDuesWithParking: nil,
          minHoaDuesWithoutParking: nil,
          maxSquareFt: 559,
          maxRentalMinIncome: 3800,
          maxPriceWithParking: nil,
          maxPriceWithoutParking: nil,
          maxPercentIncome: nil,
          max_occupancy: 2,
          maxMonthlyRent: 1900,
          maxHoaDuesWithParking: nil,
          maxHoaDuesWithoutParking: nil,
          listing_id: listing.id,
        },
      ],
    }
  end

  def self.create_chart_types(listing = nil)
    return false unless listing

    units = listing.units
    return false unless units

    chart_types = []

    units.each do |unit|
      next unless unit.ami_chart
      chart_types <<
        {
          amount: nil,
          chartId: unit.ami_chart.id,
          chartType: unit.ami_chart.chart_type,
          numOfHousehold: nil,
          percent: unit.ami_percentage,
          year: unit.ami_chart.year,
        }
    end

    chart_types
  end

  # FIXME: The below way of fetching ami mimics the SF DAHLIA Salesforce-based
  # way. This is done to quickly get AMI values up and running for a demo. For
  # the permanent solution, we should rethink how this is done in the context
  # of the regional DAHLIA app structure.
  def self.ami(opts = {})
    puts opts
    # opts = {:chartId => '1', :chartType=>"hud", :percent=>"30.0", :year=>"undefined"}
    chart = AmiChart.find(opts[:chartId])
    all_ami_values = CSV.read(chart.ami_values_file, headers: true, converters: :integer)

    percent = opts[:percent].to_i
    values_for_percent = all_ami_values.select do |row|
      row['percent_of_ami'] == percent
    end

    formatted_values = values_for_percent.map do |value|
      {
        year: opts[:year],
        percent: percent,
        numOfHousehold: value['household_size'],
        chartType: opts[:chartType],
        amount: value['income'],
      }
    end

    formatted_values.sort_by { |i| i[:numOfHousehold] }
  end
end
