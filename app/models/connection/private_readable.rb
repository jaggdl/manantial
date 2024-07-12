module Connection
  module PrivateReadable
    def latest_posts
      connection_service.get_latest_posts
    rescue Service::Error => e
      Rails.logger.error("Connection::Service error: #{e.message}")
      []
    end

    private

    def connection_service
      @service ||= Connection::Service.new(self)
    end
  end
end
