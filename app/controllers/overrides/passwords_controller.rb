module Overrides
  # Overrides to DeviseTokenAuth
  class PasswordsController < DeviseTokenAuth::PasswordsController
    # where users arrive after visiting the password reset confirmation link
    # taken from devise off and made rubocop friendly
    def edit
      @resource = resource_class.reset_password_by_token(
        reset_password_token: resource_params[:reset_password_token],
      )
      if @resource and @resource.id
        client_id  = SecureRandom.urlsafe_base64(nil, false)
        token      = SecureRandom.urlsafe_base64(nil, false)
        token_hash = BCrypt::Password.create(token)
        expiry     = (Time.now + DeviseTokenAuth.token_lifespan).to_i

        @resource.tokens[client_id] = {
          token:  token_hash,
          expiry: expiry,
        }

        save_resource_for_edit

        yield @resource if block_given?

        redirect_to(@resource.build_auth_url(
                      redirect_url,
                      token: token,
                      client_id: client_id,
                      reset_password: true,
                      config: params[:config],
        ))
      else
        render_edit_error
      end
    end

    private

    # easiest way to add this email hook without having to override the whole
    # update method from the gem
    def render_update_success
      Emailer.account_update(current_user).deliver_now
      super
    end

    # copied from gem,
    # so we can override ability to reset password without current_password
    def resource_update_method
      if params[:current_password].nil? ||
         DeviseTokenAuth.check_current_password_before_update == false ||
         @resource.allow_password_change == true
        'update_attributes'
      else
        'update_with_password'
      end
    end

    def save_resource_for_edit
      # ensure that user is confirmed
      @resource.skip_confirmation! if user_is_confirmed
      # allow user to change password once without current_password
      @resource.allow_password_change = true
      @resource.save!
    end

    def redirect_url
      root_url + 'reset-password'
    end

    def render_edit_error
      # TODO: Create a proper token expired error message?
      redirect_to root_url
    end

    def user_is_confirmed
      @resource.devise_modules.include?(:confirmable) && !@resource.confirmed_at
    end
  end
end
