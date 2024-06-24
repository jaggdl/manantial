class PostImageUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

  def filename
    original_filename
  end

  def self.version_sizes
    {
      xs: [480, nil],
      sm: [640, nil],
      md: [768, nil],
      lg: [1024, nil],
      xl: [1280, nil],
      xxl: [1536, nil]
    }
  end

  version_sizes.each do |version, size|
    version version do
      process resize_to_fit: size
      %w[webp avif].each do |format|
        version format do
          process convert: format
          process set_content_type: format
          define_method(:full_filename) do |for_file|
            "#{for_file.chomp(File.extname(for_file))}.#{format}"
          end
        end
      end
    end
  end

  def extension_allowlist
    %w[jpg jpeg png]
  end

  private

  def set_content_type(format)
    file.content_type = "image/#{format}"
  end
end
