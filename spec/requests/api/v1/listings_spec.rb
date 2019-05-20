# spec/requests/api/v1/listings_spec.rb
require 'spec_helper'

describe 'Listings API' do
  it 'sends a list of listings' do
    get '/api/v1/listings.json'

    # test for the 200 status-code
    expect(response).to be_success

    # check to make sure listings are returned
    expect(json['listings']).not_to be_empty
  end

  # it 'sends an individual listing' do
  #   VCR.use_cassette("listings/#{listing_id}") do
  #     get "/api/v1/listings/#{listing_id}.json"
  #   end

  #   json = JSON.parse(response.body)

  #   # test for the 200 status-code
  #   expect(response).to be_success

  #   # check to make sure the right Id is present
  #   expect(json['listing']['id']).to eq(listing_id)
  # end

  # it 'gets AMI results' do
  #   VCR.use_cassette('listings/ami') do
  #     params = {
  #       chartType: %w[Non-HERA HCD/TCAC Non-HERA],
  #       percent: %w[50 50 60],
  #       year: %w[2016 2016 2016],
  #     }
  #     get '/api/v1/listings/ami.json', params
  #   end

  #   json = JSON.parse(response.body)

  #   # test for the 200 status-code
  #   expect(response).to be_success

  #   # check to make sure the right amount of AMI results are returned
  #   # (based on VCR cassette with 3 different AMI levels)
  #   expect(json['ami'].length).to eq(3)
  # end

  # it 'gets Unit results for a Listing' do
  #   VCR.use_cassette('listings/units') do
  #     get "/api/v1/listings/#{listing_id}/units.json"
  #   end

  #   json = JSON.parse(response.body)

  #   # test for the 200 status-code
  #   expect(response).to be_success

  #   # check to make sure the right amount of Unit results are returned
  #   # (based on VCR listing with 1 unit)
  #   expect(json['units'].length).to eq(1)
  # end

  # it 'gets lottery preferences for a Listing' do
  #   VCR.use_cassette('listings/preferences') do
  #     get "/api/v1/listings/#{listing_id}/preferences.json"
  #   end

  #   json = JSON.parse(response.body)

  #   expect(response).to be_success

  #   expect(json['preferences'].length).to eq(6)
  # end
end
