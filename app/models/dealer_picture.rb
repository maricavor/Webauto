class DealerPicture < ActiveRecord::Base
  attr_accessible :file, :name, :remote_file_url, :user_id
  belongs_to :user
  mount_uploader :file, ImageUploader
end
