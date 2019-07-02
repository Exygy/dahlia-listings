# frozen_string_literal: true

# RESTful JSON API to query for listings
class Api::V1::ListingsController < ApiController
  before_action :set_listings_scope

  def index
    if listings_params[:ids]
      listings = @listings_scope.find(*listings_params[:ids])
    else
      listings = @listings_scope
    end

    json_listings = []

    listings.each do |listing|
      unit_summaries = ListingService.create_unit_summaries(listing)
      json_listing = listing.as_json
      json_listing[:unit_summaries] = unit_summaries
      json_listing[:units_available] = listing.units.available.count
      json_listings << json_listing
    end

    render json: { listings: json_listings }
  end

  def show
    listing = @listings_scope.find(params[:id])
    response = { listing: listing.as_json }
    ami_chart_summaries = ListingService.create_ami_chart_summaries(listing)
    unit_summaries = ListingService.create_unit_summaries(listing)
    response[:listing][:amiChartSummaries] = ami_chart_summaries
    response[:listing][:unit_summaries] = unit_summaries
    response[:listing][:total_units] = listing.units.count
    response[:listing][:units_available] = listing.units.available.count
    render json: response
  end

  def units
    listing = @listings_scope.find(params[:id])
    units = []
    if listing&.units
      units = listing.units.as_json
      units.each { |u| add_labels_to_unit(u) }
    end
    render json: { units: units }
  end

  def preferences
    listing = @listings_scope.find(params[:id])
    preferences = listing ? listing.preferences : []
    render json: { preferences: preferences }
  end

  def ami
    ami_levels = params[:chart_ids].map.with_index do |id, i|
      percent = params[:percents][i].to_i
      {
        percent: percent,
        # FIXME: get_ami_chart_values_for_percent should be a method called on
        # the AMI chart object
        values: ListingService.get_ami_chart_values_for_percent(id, percent),
      }
    end

    render json: { ami: ami_levels }
  end

  private

  def set_listings_scope
    @listings_scope = @group.listings_for_self_and_descendants
  end

  def listings_params
    params.permit(:ids)
  end

  def add_labels_to_unit(unit)
    unit['unit_type_label'] = I18n.t("unit_types.#{unit['unit_type']}")
  end
end
