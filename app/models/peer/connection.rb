module Peer
  class Connection < ApplicationRecord
    validates :hostname, presence: true, uniqueness: true, format: { with: /\A[a-zA-Z0-9][a-zA-Z0-9\-]*\.[a-zA-Z]{2,}\z/, message: "must be a valid hostname" }

    before_validation :generate_tokens, on: :create
    before_save :normalize_hostname

    enum :status, { pending: "pending", active: "active", rejected: "rejected" }, validate: true

    def accept!(their_access_key)
      self.peer_access_key = their_access_key
      self.status = :active
      save!
    end

    def reject!
      self.status = :rejected
      access_key = nil
      peer_access_key = nil
      save!
    end

    private

    def generate_tokens
      self.access_key = SecureRandom.hex(32)
      self.peer_access_key = SecureRandom.hex(32)
    end

    def normalize_hostname
      self.hostname = hostname.downcase.gsub(%r{/$}, "")
    end
  end
end
