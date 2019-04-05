module OrganizationSwitchable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_organization
  end

  def set_current_organization
    domain = params[:switch_domain] || request.host
#    session[:org] = org # not sure if we need this… -JW
    @organization = Organization.find_information_for_domain(domain)
    Organization.lookup_initials = @organization['initials']
  end
end