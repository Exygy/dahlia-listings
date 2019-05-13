# Allow setting of current request group
module GroupSwitchable
  extend ActiveSupport::Concern
  thread_mattr_accessor :current_slug

  included do
    before_action :set_current_group
  end

  def set_current_group
    domain = params[:switch_domain] || request.host
    @group = Group.for_domain(domain)
    GroupSwitchable.current_slug = @group.slug
  end
end
