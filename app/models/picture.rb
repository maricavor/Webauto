#require 'RMagick'
include Magick
class Picture < ActiveRecord::Base
  #acts_as_paranoid
  attr_accessible :file, :name, :remote_file_url, :vehicle_id,:position,:created_at,:deleted_at
  belongs_to :vehicle
  mount_uploader :file, ImageUploader
  #validate :validate_max_photos
  #after_save :add_text
  def default_name
    self.name ||= File.basename(file.filename, '.*').titleize if file
  end
  def total_amount
    Picture.find(:all,:conditions => ["vehicle_id = ?", self.vehicle_id]).count
  end
  def add_text

    mark=Magick::Image.new(300,50) do
      self.background_color='none'


    end
    gc=Magick::Draw.new
    gc.annotate(mark, 0,0,0,0, "RMagick") do
      self.gravity = Magick::CenterGravity
      self.pointsize = 32
      self.stroke = 'none'
      self.fill = '#ffffff'
    end
    mark.rotate!(-90)
    clown=Magick::Image.read(self.file).first
    clown=clown.watermark(mark,0.15,0,Magick::EastGravity)
    clown.write('watermark.jpg')

  end
  private

  def validate_max_photos
    maximum_amount_of_photos=7
    errors.add(:base,"You cannot have more than #{maximum_amount_of_photos} photos on this account.") if self.total_amount >= maximum_amount_of_photos
  end
end