module Connection::PublicReadable
  extend ActiveSupport::Concern

  included do
    def public_info
      Rails.cache.fetch(public_info_cache_key, expires_in: 1.hour) do
        response = connection_service.get("/api/v1/public/info")
        response.parsed_response
      rescue Connection::Service::Error => e
        Rails.logger.error("Connection::Service error: #{e.message}")
        nil
      rescue StandardError => e
        Rails.logger.error("General error: #{e.message}")
        nil
      end
    end

    private

    def public_info_cache_key
      "public_info/#{self.class.name.downcase}/#{self.id}"
    end

    def connection_service
      @service ||= Connection::Service.new(self.domain)
    end
  end
end
