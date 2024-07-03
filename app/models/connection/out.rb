class Connection::Out < ApplicationRecord
  validates :nonce, presence: true
  validates :domain, presence: true, uniqueness: { message: "has already been taken" }
end
