class PostImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    original_filename
  end

  version :xs do
    process resize_to_fit: [480, nil]
  end

  version :sm do
    process resize_to_fit: [640, nil]
  end

  version :md do
    process resize_to_fit: [768, nil]
  end

  version :lg do
    process resize_to_fit: [1024, nil]
  end

  version :xl do
    process resize_to_fit: [1280, nil]
  end

  version :xxl do
    process resize_to_fit: [1536, nil]
  end

  def extension_allowlist
    %w[jpg jpeg png]
  end
end
