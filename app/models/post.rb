class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  def markdown_to_html
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer, extensions = {})
    markdown.render(self.markdown).html_safe
  end
end
