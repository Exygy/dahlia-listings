# frozen_string_literal: true

# RESTful JSON API to query for listings
class Api::V1::ListingsController < ApiController
  def index
    # listings_params[:ids] could be nil which means get all open listings
    # listings_params[:ids] is a comma-separated list of ids

    # Here we use the USE_DB_FOR_LISTINGS env var to allow us to toggle
    # back and forth between using the new approach of using a Postgres
    # DB vs the old way of using Salesforce as the data source. This is
    # useful while we're in the early stages of development to allow us
    # to easily pull in data from Salesforce and check how it looks.
    # TODO: Remove this check on the USE_DB_FOR_LISTINGS env var once
    # development is far along enough that we don't need to be able to
    # switch back to Salesforce to check data.
    if ENV['USE_DB_FOR_LISTINGS'] == 'true'
      if listings_params[:ids]
        @listings = Listing.find(*listings_params[:ids])
      else
        @listings = Listing.all
      end
      @listings = @listings.map(&:to_salesforce_from_db)
    else
      @listings = Force::ListingService.listings(listings_params)
    end
    puts @listings

    render json: { listings: @listings }
  end

  def show
    # See comment above about use of the USE_DB_FOR_LISTINGS env var.
    # TODO: Remove this check on the USE_DB_FOR_LISTINGS env var once
    # development is far along enough that we don't need to be able to
    # switch back to Salesforce to check data.
    if ENV['USE_DB_FOR_LISTINGS'] == 'true'
      @listing = Listing.find(params[:id]).to_salesforce_from_db
    else
      @listing = Force::ListingService.listing(params[:id], force: params[:force])
    end

    puts @listing
    render json: { listing: @listing }
  end

  def units
    @units = Force::ListingService.units(params[:id], force: params[:force])
    render json: { units: @units }
  end

  def lottery_buckets
    @lottery_buckets = Force::ListingService.lottery_buckets(params[:id])
    render json: @lottery_buckets
  end

  def lottery_ranking
    @lottery_ranking = Force::ListingService.lottery_ranking(
      params[:id],
      params[:lottery_number],
    )
    render json: @lottery_ranking
  end

  def preferences
    @preferences = Force::ListingService.preferences(params[:id], force: params[:force])
    render json: { preferences: @preferences }
  end

  def eligibility
    # have to massage params into number values
    filters = {
      householdsize: params[:householdsize].to_i,
      incomelevel: params[:incomelevel].to_f,
      childrenUnder6: params[:childrenUnder6].to_i,
    }
    @listings = Force::ListingService.eligible_listings(filters)
    render json: { listings: @listings }
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
