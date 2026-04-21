require "net/http"

module Peers
  class Connection
    module Requests
      extend ActiveSupport::Concern

      def initiate_outgoing!(origin_host)
        generate_access_key
        save!

        peer_response = post_to_peer("/peers/connection", {
          hostname: origin_host,
          access_key: access_key
        })

        unless peer_response[:success]
          update!(error_message: "Peer did not respond to connection request")
          return
        end

        peer_nonce = peer_response[:data]["nonce"]

        unless peer_nonce.present?
          update!(error_message: "Peer returned an invalid response")
          return
        end

        self.nonce = peer_nonce
        save!
      end

      def complete_acceptance!(origin_host)
        raise "Connection is not pending" unless pending?

        generate_access_key if access_key.blank?

        confirm_response = post_to_peer("/peers/connection/confirm", {
          access_key: access_key,
          nonce: nonce,
          hostname: origin_host
        })

        if confirm_response[:success]
          self.status = :active
          save!
        else
          self.error_message = "Peer could not confirm: #{confirm_response[:error]}"
          save!
        end
      end

      def verify_peer(nonce)
        response = post_to_peer("/peers/connection/verify", { nonce: nonce })

        if response[:success]
          data = response[:data]
          data["verified"] == true && data["hostname"] == hostname
        else
          false
        end
      end

      def notify_revoke!(origin_host)
        return unless active?

        post_to_peer("/peers/connection/revoke", { hostname: origin_host })
      rescue StandardError
        # Silently fail — local record is already being deleted
      end

      def fetch_posts
        return [] unless active? && peer_access_key.present?

        response = get_from_peer("/peers/posts", headers: { "Authorization" => "Bearer #{peer_access_key}" })
        return [] unless response[:success]

        response[:data].map { |attrs| RemotePost.new(attrs.merge("hostname" => hostname)) }
      rescue StandardError
        []
      end

      private

      def fetch_user
        Rails.cache.fetch("peer_user/#{hostname}", expires_in: 30.minutes) do
          response = get_from_peer("/peers/profile")
          next nil unless response[:success]

          data = response[:data]
          PeerUser.new(
            hostname: hostname,
            name: data["name"],
            avatar_url: data["avatar_url"]
          )
        end
      rescue StandardError
        nil
      end

      def get_from_peer(path, headers: {})
        request = Net::HTTP::Get.new(path, { "Accept" => "application/json" }.merge(headers))
        perform_request(request, open_timeout: 2, read_timeout: 3)
      end

      def post_to_peer(path, payload)
        request = Net::HTTP::Post.new(path, { "Content-Type" => "application/json" })
        request.body = payload.to_json
        perform_request(request, open_timeout: 3, read_timeout: 5)
      end

      def perform_request(request, open_timeout:, read_timeout:)
        uri = URI("https://#{hostname}#{request.path}")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.open_timeout = open_timeout
        http.read_timeout = read_timeout

        response = http.request(request)

        if response.code.to_i >= 200 && response.code.to_i < 300
          { success: true, data: JSON.parse(response.body) }
        else
          { success: false, error: "HTTP #{response.code}" }
        end
      rescue StandardError => e
        { success: false, error: e.message }
      end
    end
  end
end
