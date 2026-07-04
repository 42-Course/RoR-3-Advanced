class ImageUploader < CarrierWave::Uploader::Base
  # Store every upload on Cloudinary (CDN), in all environments, as the
  # subject requires. Credentials come from ENV["CLOUDINARY_URL"].
  include Cloudinary::CarrierWave

  # A thumbnail transformation served by Cloudinary so the catalog loads fast
  # regardless of the originally uploaded image's size.
  version :thumb do
    process resize_to_fit: [200, 200]
  end

  # Validate by MIME type, not extension: remote seed images (robohash) have
  # no file extension, so an extension allowlist would reject them.
  def content_type_allowlist
    [/image\//]
  end
end
