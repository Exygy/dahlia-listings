# frozen_string_literal: true

require 'rails_helper'
require 'support/vcr_setup'

describe Api::V1::ListingsController do
  describe '#index' do
    it 'returns all 4 listings' do
      get :index
      expect(JSON.parse(response.body)['listings'].size).to eq(4)
    end

    context 'raises an error' do
      it 'returns 504 for Faraday::ConnectionFailed' do
        allow(Force::ListingService)
          .to(receive(:listings)).with({})
          .and_raise(Faraday::ConnectionFailed, 'Error')
        get :index
        expect(response.status).to eq 504
      end

      it 'returns 503 for StandardError' do
        allow(Force::ListingService)
          .to(receive(:listings)).with({})
          .and_raise(StandardError, 'Error')
        get :index
        expect(response.status).to eq 503
      end

      it 'returns 404 for APEX_ERROR' do
        allow(Force::ListingService)
          .to(receive(:listings)).with({})
          .and_raise(StandardError, 'APEX_ERROR: System.StringException: Invalid id')
        get :index
        expect(response.status).to eq 404
      end
    end
  end
end
