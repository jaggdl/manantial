module Connection
  class Set < ApplicationRecord
    include PublicReadable
    include PrivateReadable

    validates :token, presence: true
    validates :domain, presence: true, uniqueness: { message: "has already a request from you" }
  end
end
