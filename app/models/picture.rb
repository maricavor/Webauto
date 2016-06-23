

class Picture < ActiveRecord::Base
  #acts_as_paranoid
  attr_accessible :file, :name, :remote_file_url, :vehicle_id,:position,:created_at,:deleted_at,:file_cache
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
  
  private

  def validate_max_photos
    maximum_amount_of_photos=7
    errors.add(:base,"You cannot have more than #{maximum_amount_of_photos} photos on this account.") if self.total_amount >= maximum_amount_of_photos
  end
end