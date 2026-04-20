require "net/http"

module Peers
  class Connection < ApplicationRecord
    self.table_name = "connections"

    validates :hostname, presence: true, uniqueness: true, format: { with: /\A([a-z0-9]([a-z0-9\-]{0,61}[a-z0-9])?\.)+[a-z]{2,}\z/i, message: "must be a valid hostname" }

    before_validation :generate_tokens, on: :create
    before_validation :normalize_hostname

    enum :status, { pending: "pending", active: "active", rejected: "rejected" }, validate: true

    scope :ordered, -> { order(created_at: :desc) }

    def accept!(peer_access_key)
      self.peer_access_key = peer_access_key
      self.status = :active
      save!
    end

    def reject!
      self.status = :rejected
      self.access_key = nil
      self.peer_access_key = nil
      self.nonce = nil
      save!
    end

    def disconnect!
      destroy!
    end

    def notify_revoke!(origin_host)
      return unless active?

      post_to_peer("/peers/connection/revoke", { hostname: origin_host })
    rescue StandardError
      # Silently fail — local record is already being deleted
    end

    def self.initiate_outgoing!(hostname, origin_host)
      connection = create!(hostname: hostname)

      # Step 1: Call peer's create endpoint
      peer_response = post_to_peer(hostname, "/peers/connection", { hostname: origin_host })

      unless peer_response[:success]
        connection.update!(error_message: "Peer did not respond to connection request")
        return connection
      end

      peer_token = peer_response[:data]["token"]
      peer_nonce = peer_response[:data]["nonce"]

      unless peer_token.present? && peer_nonce.present?
        connection.update!(error_message: "Peer returned an invalid response")
        return connection
      end

      # Step 2: Store peer token
      connection.peer_access_key = peer_token

      # Step 3: Call peer's confirm endpoint
      confirm_response = post_to_peer(hostname, "/peers/connection/confirm", {
        access_key: connection.access_key,
        nonce: peer_nonce,
        hostname: origin_host
      })

      if confirm_response[:success]
        connection.status = :active
      else
        connection.error_message = "Peer could not confirm connection"
      end

      connection.save!
      connection
    end

    def self.normalize_hostname(hostname)
      return nil if hostname.blank?
      hostname = hostname.downcase.strip
      hostname = hostname.sub(%r{\Ahttps?://}, "")
      hostname = hostname.sub(%r{/\z}, "")
      hostname
    end

    def self.verify_peer(hostname, nonce)
      response = post_to_peer(hostname, "/peers/connection/verify", { nonce: nonce })

      if response[:success]
        data = response[:data]
        data["verified"] == true && data["hostname"] == hostname
      else
        false
      end
    end

    private

    def self.post_to_peer(hostname, path, payload)
      uri = URI("https://#{hostname}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 3
      http.read_timeout = 5

      request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
      request.body = payload.to_json

      response = http.request(request)

      if response.code.to_i >= 200 && response.code.to_i < 300
        { success: true, data: JSON.parse(response.body) }
      else
        { success: false, error: "HTTP #{response.code}" }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

    def generate_tokens
      self.access_key = SecureRandom.hex(32) if access_key.blank?
      self.nonce = SecureRandom.hex(16) if nonce.blank?
    end

    def normalize_hostname
      return if hostname.blank?
      self.hostname = self.class.normalize_hostname(hostname)
    end

    def post_to_peer(path, payload)
      self.class.post_to_peer(hostname, path, payload)
    end
  end
end
