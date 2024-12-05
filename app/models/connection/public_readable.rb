module Connection::PublicReadable
  def public_info
    @connection_info ||= connection_service.get_public_info
  rescue Connection::Service::Error => e
    Rails.logger.error("Connection::Service error: #{e.message}")
    nil
  end

  def domain_url
    "https://#{domain}"
  end

  def localized_domain_url
    localized_path = I18n.locale == I18n.default_locale ? '' : I18n.locale.to_s
    "https://#{domain}/#{localized_path}"
  end

  private

  def connection_service
    @service ||= Connection::Service.new(self)
  end
end
