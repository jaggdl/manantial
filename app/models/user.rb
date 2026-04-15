class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :posts
  has_many :api_keys, dependent: :destroy
  has_one_attached :avatar

  validates :name, presence: true, length: { maximum: 50 }
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
