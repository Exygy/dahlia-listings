# frozen_string_literal: true

# RESTful JSON API to query for listings
class Api::V1::ListingsController < ApiController
  before_action :set_listings_scope

  def index
    # listings_params[:ids] could be nil which means get all open listings
    # listings_params[:ids] is a comma-separated list of ids
    if listings_params[:ids]
      @listings = @listings_scope.find(*listings_params[:ids])
    else
      @listings = @listings_scope
    end

    @listings = @listings.as_json(include: :units).each do |listing|
      listing['units'].each { |u| add_labels_to_unit(u) }
    end

    render json: { listings: @listings }
  end

  def show
    @listing = @listings_scope.find(params[:id])
    response = { listing: @listing.as_json }
    ami_chart_summaries = ListingService.create_ami_chart_summaries(@listing)
    unit_summaries = ListingService.create_unit_summaries(@listing)
    response[:listing][:amiChartSummaries] = ami_chart_summaries
    response[:listing][:unitSummaries] = unit_summaries
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
    # TODO: Replace the below Salesforce-based way of fetching preferences
    # with the new way that will be coming in the dahlia_data_models gem.
    # @preferences = Force::ListingService.preferences(params[:id], force: params[:force])
    @preferences = []
    render json: { preferences: @preferences }
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
