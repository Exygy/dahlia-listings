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
    @listings = @listings.map(&:to_salesforce_from_db)

    render json: { listings: @listings }
  end

  def show
    @listing = @listings_scope.find(params[:id]).to_salesforce_from_db
    render json: { listing: @listing }
  end

  def units
    # TODO: Replace the below Salesforce-based way of fetching units
    # with the new way that will be coming in the dahlia_data_models gem.
    # @units = Force::ListingService.units(params[:id], force: params[:force])
    @units = []
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
end
