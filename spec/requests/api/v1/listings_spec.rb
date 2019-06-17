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
end
