class ImageUploader < CarrierWave::Uploader::Base
  # Store on Cloudinary (CDN) when configured, otherwise on local disk (dev).
  # This keeps the app buildable without any credentials while honoring the
  # subject's "use a CDN in production" requirement when CLOUDINARY_URL is set.
  if ENV["CLOUDINARY_URL"].present?
    include Cloudinary::CarrierWave

    version :thumb do
      process resize_to_fit: [200, 200]
    end
  else
    include CarrierWave::MiniMagick

    storage :file

    def store_dir
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end

    # A small thumbnail so the catalog loads quickly regardless of source size.
    version :thumb do
      process resize_to_fit: [200, 200]
    end
  end

  def extension_allowlist
    %w[jpg jpeg gif png webp]
  end
end
