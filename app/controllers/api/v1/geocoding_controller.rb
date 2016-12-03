# RESTful JSON API to query for address geocoding
class Api::V1::GeocodingController < ApiController
  GeocodingService = ArcGISService::GeocodingService
  NeighborhoodBoundaryService = ArcGISService::NeighborhoodBoundaryService

  def geocode
    render json: { geocoding_data: geocoding_data }
  end

  private

  # If we get a valid address from geocoder and a valid response from boundary service,
  # return the boundary service match response.
  # Otherwise, always return a false match so users can move on with the application
  def geocoding_data
    geocoded_addresses = GeocodingService.new(address_params).geocode
    if geocoded_addresses[:candidates].present?
      return add_neighborhood_match_data(geocoded_addresses)
    else
      ArcGISNotificationService.new(
        geocoded_addresses.merge(service_name: GeocodingService::NAME),
        log_params,
      ).send_notifications
      # default response
      { boundary_match: false }
    end
  end

  def add_neighborhood_match_data(geocoded_addresses)
    address = geocoded_addresses[:candidates].first
    x = address[:location][:x]
    y = address[:location][:y]
    name = '2198 Market' # TODO: remove hardcoded listing name
    neighborhood = NeighborhoodBoundaryService.new(name, x, y)
    match = neighborhood.in_boundary?
    # return successful geocoded data with the result of boundary_match
    return address.merge(boundary_match: match) unless neighborhood.errors.present?

    # otherwise notify of errors
    ArcGISNotificationService.new(
      {
        errors: neighborhood.errors,
        service_name: NeighborhoodBoundaryService::NAME,
      },
      log_params,
    ).send_notifications
    # default response
    { boundary_match: false }
  end

  def address_params
    params.require(:address).permit(:address1, :city, :zip)
  end

  def member_params
    params.require(:member).permit(:firstName, :lastName, :dob)
  end

  def applicant_params
    params.require(:applicant).permit(:firstName, :lastName, :dob)
  end

  def listing_params
    params.require(:listing).permit(:Id, :Name)
  end

  def log_params
    {
      address: address_params[:address1],
      city: address_params[:city],
      zip: address_params[:zip],
      member: member_params.as_json,
      applicant: applicant_params.as_json,
      listing_id: listing_params[:Id],
    }
  end
end
