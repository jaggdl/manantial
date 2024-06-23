class Post < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  extend Mobility
  translates :title, type: :string
  translates :markdown, :description, type: :text
  translates :og_image, type: :string

  mount_uploader :image, PostImageUploader
  mount_uploader :og_image, PostOgImageUploader

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

  OG_IMAGE_DIMENSIONS = {
    width: 1200,
    height: 630
  }.freeze

  def enqueue_og_image_generation
    OgImageGeneratorJob.perform_later(self.id)
  end
end
