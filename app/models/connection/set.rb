class Connection::Set < ApplicationRecord
  include PublicReadable

  validates :token, presence: true
  validates :domain, presence: true, uniqueness: { message: "has already a request from you" }
end
