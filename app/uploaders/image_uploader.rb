# encoding: utf-8

class ImageUploader < CarrierWave::Uploader::Base

  after :store, :delete_original_file



  # Include RMagick or MiniMagick support:
  include CarrierWave::RMagick
  # include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  def delete_original_file(new_file)
    # File.delete path if version_name.blank?
    if self.version_name.nil?
      self.file.delete if self.file.exists?
    end

  end
  def cache_dir
    "#{Rails.root}/tmp/uploads/cache/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    #for production--> "#{Rails.root}/public/uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.vehicle.id}/#{model.id}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    
    # For Rails 3.1+ asset pipeline compatibility:
    # ActionController::Base.helpers.asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
    "/thumbnail.png"
    #"/images/fallback/" + [version_name, "default.png"].compact.join('_')
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  version :original do
    #process :copyright=>'Webauto '
    process :resize_to_limit => [1000, 10000]
    process :watermark, :if=> :picture?
    #######
    def picture?(file)
      model.class.to_s.underscore=="picture"
    end
  end

  version :thumb do
    process :resize_to_fill => [300, 200],:if=> :picture?
     def picture?(file)
      model.class.to_s.underscore=="picture"
    end
  end
  ###
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(jpg jpeg gif png)
  end
  def watermark
    manipulate! do |img|
      logo = Magick::Image.read("#{Rails.root}/public/watermark.png").first
      img = img.composite(logo, Magick::SouthEastGravity, 10, 5, Magick::OverCompositeOp)
    end


  end

  def copyright(str)


    manipulate! format: "jpg" do |source|
      mark = Magick::Image.new(source.columns, source.rows)

      gc = Magick::Draw.new
      gc.gravity = Magick::NorthEastGravity
      gc.pointsize = 20
      gc.font_weight = Magick::BoldWeight
      gc.stroke = 'none'
      gc.annotate(mark, 0, 0, 0, 0, str)

      mark = mark.shade(true, 310, 30)

      source.composite!(mark, Magick::CenterGravity, Magick::HardLightCompositeOp)
    end
  end
  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

end