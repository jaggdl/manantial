class Connection::Set < ApplicationRecord
  validates :token, presence: true
  validates :domain, presence: true, uniqueness: { message: "has already a request from you" }
end
