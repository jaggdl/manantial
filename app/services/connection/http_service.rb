module Connection
  class HttpService
    include HTTParty

    class HttpServiceError < StandardError; end

    def initialize(domain)
      self.class.base_uri("https://#{domain}")
      @headers = { 'Content-Type' => 'application/json' }
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
      if response.success?
        response
      else
        full_url = self.class.base_uri + path
        raise HttpServiceError, "HTTP request to #{full_url} failed with code #{response.code}: #{response.message}"
      end
    end
  end
end
