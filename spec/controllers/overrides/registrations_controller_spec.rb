require 'rails_helper'

describe Overrides::RegistrationsController do
  before(:each) do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'create' do
    let(:valid_user_params) do
      {
        user: {
          email: 'jane@doe.com',
          password: 'somepassword',
          password_confirmation: 'somepassword',
        },
        contact: {
          firstName: 'Jane',
          lastName: 'Doe',
          DOB: '1985-07-23',
          email: 'jane@doe.com',
        },
        confirm_success_url: 'http://localhost/my-account',
      }
    end

    let(:salesforce_response) do
      {
        firstName: 'Test',
        lastName: 'lastName',
        email: 'test@test.com',
        DOB: '1989-03-29',
        contactId: '0036C000001sI5oQAE',
      }.as_json
    end

    it 'saves a salesforce contact id on user' do
      allow(Force::AccountService)
        .to receive(:create_or_update)
        .and_return(salesforce_response)

      VCR.use_cassette('account/register') do
        post :create, valid_user_params
      end

      expect(assigns(:resource).salesforce_contact_id)
        .to eq('0036C000001sI5oQAE')
    end
  end
end
