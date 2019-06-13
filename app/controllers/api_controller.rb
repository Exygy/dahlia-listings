require 'faraday'
# Root controller from which all our API controllers inherit.
class ApiController < ActionController::API
  include GroupSwitchable
  respond_to :json
end
