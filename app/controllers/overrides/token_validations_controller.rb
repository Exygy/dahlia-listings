module Overrides
  # Overrides to DeviseTokenAuth
  class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
    private

    def render_validate_token_success
      render json: {
        success: true,
        data: @resource.as_json.merge(salesforce_contact_data),
      }
    end

    def salesforce_contact_data
      return {} unless @resource.salesforce_contact_id.present?
      AccountService.get(@resource.salesforce_contact_id) || {}
    end
  end
end
