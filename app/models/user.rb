class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :destroy do
    def create_from_markdown!(attributes)
      body = attributes[:body] || attributes["body"]
      title = attributes[:title] || attributes["title"]
      html_body = Post.markdown_to_html(body)
      create!(title: title, body: html_body)
    end
  end
  has_many :api_keys, dependent: :destroy
  has_one_attached :avatar

  validates :name, presence: true, length: { maximum: 50 }
  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
