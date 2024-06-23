class OgImageGeneratorJob < ApplicationJob
  queue_as :default

  def perform(post_id)
    post = Post.find(post_id)
    generate_og_image(post)
  end

  private

  def generate_og_image(post)
    I18n.available_locales.each do |locale|
      I18n.with_locale(locale) do
        store_og_image(post, locale)
      end
    end
  end

  def store_og_image(post, locale)
    require 'tempfile'

    image_file = Tempfile.new(['generated_image', '.png'])
    image_file.close

    system("wkhtmltoimage --quality 90 --width #{Post::OG_IMAGE_DIMENSIONS[:width]} --height #{Post::OG_IMAGE_DIMENSIONS[:height]} #{ENV['DOMAIN']}/#{locale}/blog/#{post.slug}/og_image #{image_file.path}")

    Mobility.with_locale(locale) do
      post.update(og_image: File.open(image_file.path))
    end

    image_file.unlink
  end
end
