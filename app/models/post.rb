class Post < ApplicationRecord
  belongs_to :user

  validates :body, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create
  before_save :extract_title_from_markdown_if_missing

  scope :articles, -> { where.not(title: nil) }
  scope :regular_posts, -> { where(title: nil) }

  def article?
    title.present? || body.length > 280 || @had_h1
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?

    base_text = title.presence || body.to_s.split("\n").first || "post"
    base_slug = base_text.parameterize[0..50].gsub(/-$/, "")
    hex_hash = SecureRandom.hex(2)
    self.slug = "#{base_slug}-#{hex_hash}"
  end

  def extract_title_from_markdown_if_missing
    return if title.present?

    match = body.match(/^#\s+(.+?)(?:\n+|$)/)
    if match
      @had_h1 = true
      self.title = match[1]
      self.body = body.sub(match[0], "").strip
    end
  end
end
