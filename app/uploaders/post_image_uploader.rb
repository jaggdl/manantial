class PostImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  VERSIONS = {
    xs: [480, nil],
    sm: [640, nil],
    md: [768, nil],
    lg: [1024, nil],
    xl: [1280, nil],
    xxl: [1536, nil]
  }.freeze

  VERSIONS.each do |version_name, dimensions|
    version version_name do
      process resize_to_fit: dimensions

      version :avif do
        process convert: 'avif'
        def full_filename(for_file)
          "#{version_name}_#{File.basename(for_file, '.*')}.avif"
        end
      end

      version :webp do
        process convert: 'webp'
        def full_filename(for_file)
          "#{version_name}_#{File.basename(for_file, '.*')}.webp"
        end
      end
    end
  end

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    original_filename
  end

  def extension_allowlist
    %w[jpg jpeg png avif webp]
  end

  def asset_host
    ENV['DOMAIN']
  end
end
