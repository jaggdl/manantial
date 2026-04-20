module Peers
  class Connection < ApplicationRecord
    self.table_name = "connections"

    validates :hostname, presence: true, uniqueness: true, format: { with: /\A([a-z0-9]([a-z0-9\-]{0,61}[a-z0-9])?\.)+[a-z]{2,}\z/i, message: "must be a valid hostname" }

    before_validation :generate_tokens, on: :create
    before_validation :normalize_hostname

    enum :status, { pending: "pending", active: "active", rejected: "rejected" }, validate: true

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

      uri = URI("https://#{hostname}/peers/connection/revoke")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 3
      http.read_timeout = 5

      request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
      request.body = { hostname: origin_host }.to_json

      http.request(request)
    rescue StandardError
      # Silently fail — local record is already being deleted
    end

    def self.normalize_hostname(hostname)
      return nil if hostname.blank?
      hostname = hostname.downcase.strip
      hostname = hostname.sub(%r{\Ahttps?://}, "")
      hostname = hostname.sub(%r{/\z}, "")
      hostname
    end

    def self.verify_peer(hostname, nonce)
      uri = URI("https://#{hostname}/peers/connection/verify")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 3
      http.read_timeout = 5

      request = Net::HTTP::Post.new(uri.path, { "Content-Type" => "application/json" })
      request.body = { nonce: nonce }.to_json

      response = http.request(request)

      if response.code == "200"
        data = JSON.parse(response.body)
        data["verified"] == true && data["hostname"] == hostname
      else
        false
      end
    rescue StandardError
      false
    end

    private

    def generate_tokens
      self.access_key = SecureRandom.hex(32) if access_key.blank?
      self.nonce = SecureRandom.hex(16) if nonce.blank?
    end

    def normalize_hostname
      return if hostname.blank?
      self.hostname = self.class.normalize_hostname(hostname)
    end
  end
end
