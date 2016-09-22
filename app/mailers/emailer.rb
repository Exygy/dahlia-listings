# basic emailer class
class Emailer < Devise::Mailer
  include ActionMailer::Text
  default from: 'DAHLIA <dahlia@housing.sfgov.org>'
  layout 'email'

  ### service external methods
  def account_update(record)
    load_salesforce_contact(record)
    @email = record.email
    @subject = 'DAHLIA SF Housing Portal Account Updated'
    sign_in_path = 'sign-in?redirectTo=dahlia.account-settings'
    @account_settings_url = "#{base_url}/#{sign_in_path}"
    mail(to: @email, subject: @subject) do |format|
      format.html { render 'account_update' }
    end
  end

  def submission_confirmation(params)
    listing = Hashie::Mash.new(ListingService.listing(params[:listing_id]))
    @name = "#{params[:firstName]} #{params[:lastName]}"
    return false unless listing.present? && params[:email].present?
    _submission_confirmation_email(
      email: params[:email],
      listing: listing,
      listing_url: "#{base_url}/listings/#{listing.Id}",
      lottery_number: params[:lottery_number],
    )
  end

  def confirmation_instructions(record, token, opts = {})
    load_salesforce_contact(record)
    if record.pending_reconfirmation?
      action = :reconfirmation_instructions
    else
      action = :confirmation_instructions
    end

    @token = token
    devise_mail(record, action, opts)
  end

  def reset_password_instructions(record, token, opts = {})
    load_salesforce_contact(record)
    super
  end

  private

  def load_salesforce_contact(record)
    contact = AccountService.get(record.salesforce_contact_id)
    @name = name(contact, record)
  end

  def _submission_confirmation_email(params)
    # expects :email, :listing, :listing_url, :lottery_number
    @email = params[:email]
    @listing = params[:listing]
    @listing_name = @listing.Name
    @listing_url = params[:listing_url]
    @lottery_number = params[:lottery_number]
    @lottery_date = Date.parse(@listing.Lottery_Date).strftime('%B %e, %Y')
    @subject = "Thanks for applying to #{@listing_name}"
    mail(to: @email, subject: @subject) do |format|
      format.html { render 'submission_confirmation' }
    end
  end

  def name(contact, record)
    if contact.present?
      "#{contact['firstName']} #{contact['lastName']}"
    else
      record.email
    end
  end

  def base_url
    url_options = Rails.application.config.action_mailer.default_url_options
    ssl = Rails.application.config.force_ssl
    url = "http#{ssl ? 's' : ''}://#{url_options[:host]}"
    url = "#{url}:#{url_options[:port]}" if url_options[:port].present?
    url
  end
end
