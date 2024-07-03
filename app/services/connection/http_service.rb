# app/services/connection/http_service.rb
module Connection
  class HttpService
    include HTTParty

    class HttpServiceError < StandardError; end

    def initialize(base_url)
      self.class.base_uri(base_url)
    end

    def get(path, options = {})
      handle_response(self.class.get(path, options), path)
    end

    def post(path, options = {})
      handle_response(self.class.post(path, options), path)
    end

    def put(path, options = {})
      handle_response(self.class.put(path, options), path)
    end

    def delete(path, options = {})
      handle_response(self.class.delete(path, options), path)
    end

    private

    def handle_response(response, path)
      if response.success?
        response
      else
        full_url = self.class.base_uri + path
        raise HttpServiceError, "HTTP request to #{full_url} failed with code #{response.code}: #{response.message}"
      end
    end
  end
end
