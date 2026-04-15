class Post < ApplicationRecord
  belongs_to :user

  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: :create
  before_save :extract_title_from_markdown_if_missing

  has_rich_text :body

  scope :articles, -> { where.not(title: nil) }
  scope :regular_posts, -> { where(title: nil) }

  PREVIEW_LENGTH = 160

  def preview
    body
  end

  def article?
    title.present? || (body&.to_plain_text&.length || 0) > 280 || @had_h1
  end

  def formatted_date
    created_at.strftime("%Y.%m.%d · %H:%M")
  end

  def post_type
    article? ? "article" : "post"
  end

  def to_param
    slug
  end

  private

  def generate_slug
    return if slug.present?

    body_text = body&.to_plain_text || ""
    base_text = title.presence || body_text.split("\n").first || "post"
    base_slug = base_text.parameterize[0..50].gsub(/-$/, "")
    hex_hash = SecureRandom.hex(2)
    self.slug = "#{base_slug}-#{hex_hash}"
  end

  def extract_title_from_markdown_if_missing
    return if title.present?
    return unless body.present?

    plain_body = body.to_plain_text
    match = plain_body.match(/^#\s+(.+?)(?:\n+|$)/)
    if match
      @had_h1 = true
      self.title = match[1]
      # Update the rich text body by removing the H1 line
      new_body = plain_body.sub(match[0], "").strip
      self.body = ActionText::Content.new(new_body)
    end
  end
end
