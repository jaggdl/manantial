class PostOgImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}/#{I18n.locale}"
  end

  def extension_whitelist
    ['png']
  end

  def filename
    'og_image.png' if original_filename
  end
end
