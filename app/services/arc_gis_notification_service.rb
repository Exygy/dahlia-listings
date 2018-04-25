# Sends email notifications related to geocoding errors
class ArcGISNotificationService
  def initialize(service_data, log_params, has_nrhp_adhp)
    @service_data = service_data
    @log_params = log_params
    @has_nrhp_adhp = has_nrhp_adhp
  end

  def send_notifications
    notifications_sent = false

    if @service_data[:candidates] &&
       @service_data[:candidates].empty? &&
       # Send notification of address not found only if address
       # is in San Francisco
       @log_params[:city].casecmp('San Francisco').zero?
      send_address_notification
      notifications_sent = true
    end

    if @service_data[:errors].present?
      send_error_notification
      notifications_sent = true
    end

    notifications_sent
  end

  def send_address_notification
    log_id = GeocodingLog.create(@log_params)
    Emailer.geocoding_log_notification(log_id, @has_nrhp_adhp).deliver_later
  end

  def send_error_notification
    params = [@service_data, @log_params, @has_nrhp_adhp].as_json
    Emailer.geocoding_error_notification(*params).deliver_later
  end
end
