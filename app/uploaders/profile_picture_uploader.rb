class ProfilePictureUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  storage :file

  VERSIONS = {
    xs: [64, 64],
    sm: [128, 128],
    md: [640, 640],
    lg: [1024, 1024],
    xl: [1280, 1280]
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

  def extension_allowlist
    %w[jpg jpeg png avif webp]
  end

  def filename
    "#{secure_token}.#{file.extension}" if original_filename.present?
  end

  def asset_host
    ENV['DOMAIN']
  end

  protected

  def secure_token
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) || model.instance_variable_set(var, SecureRandom.uuid)
  end
end
