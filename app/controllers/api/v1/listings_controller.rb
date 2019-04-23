# frozen_string_literal: true

# RESTful JSON API to query for listings
class Api::V1::ListingsController < ApiController
  def index
    # listings_params[:ids] could be nil which means get all open listings
    # listings_params[:ids] is a comma-separated list of ids
    @listings = listings_params[:ids] ? Listing.find(*listings_params[:ids]) : Listing.all
    @listings = @listings.map(&:to_salesforce_from_db)

    render json: { listings: @listings }
  end

  def show
    @listing = Listing.find(params[:id]).to_salesforce_from_db
    render json: { listing: @listing }
  end

  def units
    @units = Force::ListingService.units(params[:id], force: params[:force])
    render json: { units: @units }
  end

  def preferences
    @preferences = Force::ListingService.preferences(params[:id], force: params[:force])
    render json: { preferences: @preferences }
  end

  def ami
    # loop through all the ami levels that you just sent me
    # call Force::ListingService.ami with each set of opts
    @ami_levels = []
    params[:chartType].each_with_index do |chart_type, i|
      data = {
        chartType: chart_type,
        percent: params[:percent][i],
        year: params[:year][i],
      }
      @ami_levels << {
        percent: data[:percent],
        values: Force::ListingService.ami(data),
      }
    end
    render json: { ami: @ami_levels }
  end

  private

  def listings_params
    params.permit(:ids, :Tenure)
  end
end
