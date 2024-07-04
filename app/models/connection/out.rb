module Connection
  class Out < ApplicationRecord
    include PublicReadable

    validates :nonce, presence: true
    validates :domain, presence: true, uniqueness: { message: "has already a request from you" }
  end
end
