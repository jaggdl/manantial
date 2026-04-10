class Post < ApplicationRecord
  belongs_to :user

  validates :body, presence: true

  before_save :extract_title_from_markdown_if_missing

  scope :articles, -> { where.not(title: nil) }
  scope :regular_posts, -> { where(title: nil) }

  def article?
    title.present? || body.length > 280 || @had_h1
  end

  private

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
