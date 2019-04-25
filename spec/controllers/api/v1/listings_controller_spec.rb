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
      it 'returns 503 for StandardError' do
        get :index
        expect(response.status).to eq 503
      end
    end
  end
end
