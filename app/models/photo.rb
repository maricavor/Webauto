class Photo < ActiveRecord::Base
  require 'paperclip_processors/watermark'
  attr_accessible :image, :name, :vehicle_id,:position,:created_at,:deleted_at
  belongs_to :vehicle
  # preserve_files: "true"
  has_attached_file :image,processors:[:watermark],:styles=> {:original => {:geometry => "1000x1000>",:watermark_path => "#{Rails.root}/public/watermark.png" },:thumb=>"450x300#",:small => "600x600>"},convert_options: { thumb: "-quality 75 -strip",original: "-quality 85 -strip" },:storage => :s3, :default_url =>  "#{Rails.root}/public/thumbnail.png"

  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_content_type :image, :content_type => ["image/jpeg", "image/gif", "image/png"]
  before_post_process :check_file_size
  #process_in_background :image, only_process: [:original,:small]
  
 
    def total_amount
      Photo.find(:all,:conditions => ["vehicle_id = ?", self.vehicle_id]).count
    end
  private 
  
 
  
  def check_file_size
    valid?
    errors[:image_file_size].blank?
  end
 
end
#change size of thumb smaller
