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
    unit_summaries = ListingService.create_unit_summaries(@listing)
    response[:listing][:unitSummaries] = unit_summaries
    render json: response
  end

  def units
    @listing = @listings_scope.find(params[:id])
    @units = []
    if @listing&.units
      @units = @listing.units.as_json
      @units.each { |u| add_labels_to_unit(u) }
    end
    render json: { units: @units }
  end

  def preferences
    # TODO: Replace the below Salesforce-based way of fetching preferences
    # with the new way that will be coming in the dahlia_data_models gem.
    # @preferences = Force::ListingService.preferences(params[:id], force: params[:force])
    @preferences = []
    render json: { preferences: @preferences }
  end

  def ami
    # loop through all the ami levels that you just sent me
    # call Force::ListingService.ami with each set of opts
    @ami_levels = []

    # TODO: Replace the below Salesforce-based way of fetching ami
    # with the new way that will be coming in the dahlia_data_models gem.
    # params[:chartType].each_with_index do |chart_type, i|
    #   data = {
    #     chartType: chart_type,
    #     percent: params[:percent][i],
    #     year: params[:year][i],
    #   }
    #   @ami_levels << {
    #     percent: data[:percent],
    #     values: Force::ListingService.ami(data),
    #   }
    # end

    render json: { ami: @ami_levels }
  end

  private

  def set_listings_scope
    @listings_scope = @group.listings_for_self_and_descendants
  end

  def listings_params
    params.permit(:ids, :Tenure)
  end

  def add_labels_to_unit(unit)
    unit['unit_type_label'] = I18n.t("unit_types.#{unit['unit_type']}")
  end
end
