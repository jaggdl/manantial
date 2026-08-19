module OgMetadata
  extend ActiveSupport::Concern

  def og_title
    (title&.strip || body.to_plain_text.truncate(100)).truncate(55)
  end

  def og_description
    body.to_plain_text.truncate(140)
  end

  def og_image_url(view_context)
    image = preview_images.first
    return nil unless image

    view_context.url_for(image.representation(resize_to_limit: [800, 800]))
  end

  def og_metadata(view_context)
    {
      title: og_title,
      description: og_description,
      image: og_image_url(view_context)
    }
  end
end