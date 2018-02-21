# RESTful JSON API to query for listings
class Api::V1::ListingsController < ApiController
  ListingService = SalesforceService::ListingService

  def index
    # params[:ids] could be nil which means get all open listings
    # params[:ids] is a comma-separated list of ids
    @listings = ListingService.listings(params[:ids])
    render json: { listings: @listings }
  end

  def show
    @listing = ListingService.listing(params[:id])
    render json: { listing: @listing }
  end

  def units
    @units = ListingService.units(params[:id])
    render json: { units: @units }
  end

  def lottery_buckets
    @lottery_buckets = ListingService.lottery_buckets(params[:id])
    render json: @lottery_buckets
  end

  def lottery_ranking
    @lottery_ranking = ListingService.lottery_ranking(
      params[:id],
      params[:lottery_number],
    )
    render json: @lottery_ranking
  end

  def preferences
    @preferences = ListingService.preferences(params[:id])
    render json: { preferences: @preferences }
  end

  def eligibility
    # have to massage params into number values
    filters = {
      householdsize: params[:householdsize].to_i,
      incomelevel: params[:incomelevel].to_f,
      childrenUnder6: params[:childrenUnder6].to_i,
    }
    @listings = ListingService.eligible_listings(filters)
    render json: { listings: @listings }
  end

  def ami
    # loop through all the ami levels that you just sent me
    # call ListingService.ami with each set of opts
    @ami_levels = []
    params[:chartType].each_with_index do |chart_type, i|
      data = {
        chartType: chart_type,
        percent: params[:percent][i],
        year: params[:year][i],
      }
      @ami_levels << {
        percent: data[:percent],
        values: ListingService.ami(data),
      }
    end
    render json: { ami: @ami_levels }
  end
end
