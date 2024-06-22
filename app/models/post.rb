class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  extend Mobility
  translates :title, type: :string
  translates :markdown, :description, type: :text

  mount_uploader :image, PostImageUploader

  with_options presence: true do
    validates :title
    validates :markdown
    validates :description
    validates :image
  end

  def markdown_to_html
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer, extensions = {})
    markdown.render(self.markdown).html_safe
  end
end
