module Connection::PublicReadable
  def public_info
    connection_service.get_public_info
  rescue Connection::Service::Error => e
    Rails.logger.error("Connection::Service error: #{e.message}")
    nil
  end

  private

  def connection_service
    @service ||= Connection::Service.new(self)
  end
end
