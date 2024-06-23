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

  def generate_og_image
    I18n.available_locales.each do |locale|
      I18n.with_locale(locale) do
        store_og_image(locale)
      end
    end
  end

  OG_IMAGE_DIMENSIONS = {
    :width =>1200,
    :height => 630
  }.freeze

  private

  def store_og_image(locale)
    require 'tempfile'

    image_file = Tempfile.new(['generated_image', '.png'])
    image_file.close

    system("wkhtmltoimage --quality 90 --width #{OG_IMAGE_DIMENSIONS[:width]} --height #{OG_IMAGE_DIMENSIONS[:height]} http://localhost:4200/#{locale.to_s}/blog/#{self.slug}/og_image #{image_file.path}")

    Mobility.with_locale(locale) do
      self.og_image = File.open(image_file.path)
      save
    end

    image_file.unlink
  end
end
