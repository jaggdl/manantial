module Peers
  class Connection < ApplicationRecord
    self.table_name = "connections"

    include Requests

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

    def self.normalize_hostname(hostname)
      return nil if hostname.blank?
      hostname = hostname.downcase.strip
      hostname = hostname.sub(%r{\Ahttps?://}, "")
      hostname = hostname.sub(%r{/\z}, "")
      hostname
    end

    def generate_access_key
      self.access_key = SecureRandom.hex(32) if access_key.blank?
    end

    def user
      @user ||= fetch_user || PeerUser.new(hostname: hostname, name: hostname, avatar_url: nil)
    end

    private

    def generate_nonce
      self.nonce = SecureRandom.hex(16) if nonce.blank?
    end

    def normalize_hostname
      return if hostname.blank?
      self.hostname = self.class.normalize_hostname(hostname)
    end
  end
end
