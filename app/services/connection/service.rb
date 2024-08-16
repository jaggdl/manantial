module Connection
  class Service
    include HTTParty
    include Rails.application.routes.url_helpers

    class Connection::Service::Error < StandardError; end

    def initialize(connection)
      @connection = connection

      self.class.base_uri("https://#{@connection.domain}")

      origin_url = URI(ENV['DOMAIN'])

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

    def get_latest_posts
      cache_fetch(:get_latest_posts, expires_in: 2.minutes) do
        get(latest_posts_api_v1_private_path)
      end
    end

    def get_public_info
      cache_fetch(:get_public_info, expires_in: 10.minutes) do
        get('/api/v1/public/info')
      end
    end

    def get_post(post_id)
      cache_fetch(:get_post, expires_in: 10.minutes) do
        get("/api/v1/posts/#{post_id}")
      end
    end

    private

    def cache_fetch(method, expires_in:, &block)
      cache_key = "#{method}/#{self.class.name.downcase}/#{self.connection_id}"
      Rails.cache.fetch(cache_key, expires_in: expires_in, &block)
    end

    def get(path, options = {})
      options[:headers] = @headers.merge(options[:headers] || {})
      handle_response { self.class.get(path, options) }
    end

    def post(path, options = {})
      options[:headers] = @headers.merge(options[:headers] || {})
      options[:body] = options[:body].to_json if options[:body]
      handle_response { self.class.post(path, options) }
    end

    def handle_response
      response = yield
      full_url = response.request.last_uri.to_s

      if response.is_a?(HTTParty::Response)
        unless response.success?
          raise Error, "HTTP request to #{full_url} failed with code #{response.code}: #{response.message}"
        end

        if response.headers['content-type']&.include?('application/json')
          response.parsed_response
        else
          raise Error, "Unexpected content type: #{response.headers['content-type']}"
        end
      else
        raise Error, "Network error while accessing #{full_url}: #{response.message}"
      end

    rescue SocketError => e
      raise Error, "Failed to open TCP connection to #{full_url} (#{e.message})"
    rescue Timeout::Error => e
      raise Error, "Request to #{full_url} timed out (#{e.message})"
    rescue StandardError => e
      raise Error, "An error occurred while accessing #{full_url}: #{e.message}"
    end

    def connection_id
      @connection.id
    end
  end
end
