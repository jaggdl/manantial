require "net/http"

module Peers
  class Connection < ApplicationRecord
    self.table_name = "connections"

    validates :hostname, presence: true, uniqueness: true, format: { with: /\A([a-z0-9]([a-z0-9\-]{0,61}[a-z0-9])?\.)+[a-z]{2,}\z/i, message: "must be a valid hostname" }

    before_validation :generate_nonce, on: :create
    before_validation :normalize_hostname

    enum :status, { pending: "pending", active: "active", rejected: "rejected" }, validate: true

    scope :ordered, -> { order(created_at: :desc) }
    scope :incoming, -> { pending.where.not(peer_access_key: nil).where(access_key: nil) }
    scope :outgoing, -> { pending.where.not(access_key: nil).where(peer_access_key: nil) }

    def accept!(peer_access_key = nil)
      generate_access_key if access_key.blank?
      self.peer_access_key = peer_access_key if peer_access_key.present?
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
      connection = new(hostname: hostname)
      connection.generate_access_key
      connection.save!

      # Call peer's create endpoint with our token
      peer_response = post_to_peer(hostname, "/peers/connection", {
        hostname: origin_host,
        access_key: connection.access_key
      })

      unless peer_response[:success]
        connection.update!(error_message: "Peer did not respond to connection request")
        return connection
      end

      peer_nonce = peer_response[:data]["nonce"]

      unless peer_nonce.present?
        connection.update!(error_message: "Peer returned an invalid response")
        return connection
      end

      connection.nonce = peer_nonce
      connection.save!
      connection
    end

    def self.complete_acceptance!(hostname, origin_host)
      connection = find_by!(hostname: hostname)

      unless connection.pending?
        raise "Connection is not pending"
      end

      connection.generate_access_key if connection.access_key.blank?

      confirm_response = post_to_peer(hostname, "/peers/connection/confirm", {
        access_key: connection.access_key,
        nonce: connection.nonce,
        hostname: origin_host
      })

      if confirm_response[:success]
        connection.status = :active
        connection.save!
      else
        connection.error_message = "Peer could not confirm: #{confirm_response[:error]}"
        connection.save!
      end

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

    def generate_access_key
      self.access_key = SecureRandom.hex(32) if access_key.blank?
    end

    def user
      @user ||= fetch_user || PeerUser.new(hostname: hostname, name: hostname, avatar_url: nil)
    end

    def fetch_posts
      return [] unless active? && peer_access_key.present?

      response = self.class.get_from_peer(hostname, "/peers/posts", headers: { "Authorization" => "Bearer #{peer_access_key}" })
      return [] unless response[:success]

      response[:data].map { |attrs| RemotePost.new(attrs.merge("hostname" => hostname)) }
    rescue StandardError
      []
    end

    private

    def fetch_user
      Rails.cache.fetch("peer_user/#{hostname}", expires_in: 30.minutes) do
        response = self.class.get_from_peer(hostname, "/peers/profile")
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

    def self.get_from_peer(hostname, path, headers: {})
      uri = URI("https://#{hostname}#{path}")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 2
      http.read_timeout = 3

      request = Net::HTTP::Get.new(uri.path, { "Accept" => "application/json" }.merge(headers))
      response = http.request(request)

      if response.code.to_i >= 200 && response.code.to_i < 300
        { success: true, data: JSON.parse(response.body) }
      else
        { success: false, error: "HTTP #{response.code}" }
      end
    rescue StandardError => e
      { success: false, error: e.message }
    end

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

    def generate_nonce
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
