module Connection
  class Service
    include HTTParty
    include Rails.application.routes.url_helpers

    class Error < StandardError; end

    def initialize(target_domain)
      origin_url = URI(ENV['DOMAIN'])

      self.class.base_uri("https://#{target_domain}")

      @headers = {
        'Content-Type' => 'application/json',
        'X-Origin-Domain' => origin_url.hostname
      }
    end

    def request_connection(message:, nonce:)
      post(connection_in_index_path, body: {
        message:,
        nonce:,
      })
    end

    def set_connection(token:, nonce:)
      post(connection_set_index_path, body: {
        token:,
        nonce:,
      })
    end

    def get(path, options = {})
      options[:headers] = @headers.merge(options[:headers] || {})
      handle_response(self.class.get(path, options), path)
    end

    def post(path, options = {})
      options[:headers] = @headers.merge(options[:headers] || {})
      options[:body] = options[:body].to_json if options[:body]
      handle_response(self.class.post(path, options), path)
    end

    def put(path, options = {})
      options[:headers] = @headers.merge(options[:headers] || {})
      options[:body] = options[:body].to_json if options[:body]
      handle_response(self.class.put(path, options), path)
    end

    def delete(path, options = {})
      options[:headers] = @headers.merge(options[:headers] || {})
      options[:body] = options[:body].to_json if options[:body]
      handle_response(self.class.delete(path, options), path)
    end

    private

    def handle_response(response, path)
      unless response.success?
        full_url = self.class.base_uri + path
        raise Error, "HTTP request to #{full_url} failed with code #{response.code}: #{response.message}"
      end

      if response.headers['content-type']&.include?('application/json')
        response
      else
        raise Error, "Unexpected content type: #{response.headers['content-type']}"
      end
    end
  end
end
