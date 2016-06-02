class AvatarUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  process resize_to_limit: [144, 144]

  process convert: 'jpg'

  def size_range
    0...100000
  end

  def extension_white_list
    %w(jpg jpeg)
  end

  def content_type_whitelist
    /image\//
  end
end
