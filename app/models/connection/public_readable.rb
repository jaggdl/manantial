module Connection::PublicReadable
  extend ActiveSupport::Concern

  included do
    def public_info
      Rails.cache.fetch(public_info_cache_key, expires_in: 1.hour) do
        response = HTTParty.get("https://#{self.domain}/api/v1/connection/public_info")

        if response.headers['content-type']&.include?('application/json')
          response.parsed_response
        else
          Rails.logger.error("Unexpected content type: #{response.headers['content-type']}")
          nil
        end
      rescue HTTParty::Error => e
        Rails.logger.error("HTTParty error: #{e.message}")
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
  end
end
