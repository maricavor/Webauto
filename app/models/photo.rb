class Photo < ActiveRecord::Base
  attr_accessible :image
  # preserve_files: "true"
  has_attached_file :image,styles: { thumb: ["450x300#", :jpg],original: ['1500x1500>', :jpg] },convert_options: { thumb: "-quality 75 -strip",original: "-quality 85 -strip" },:storage => :fog,:fog_credentials => Proc.new{|a| a.instance.fog_credentials },:fog_directory => "webauto"

  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_content_type :image, :content_type => ["image/jpeg", "image/gif", "image/png"]
 
  def fog_credentials
      {:provider=> "AWS", :aws_access_key_id => "AKIAIVRLUKEBKRXEDCMQ", :aws_secret_access_key => "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",:region => 'eu-central-1'}
    end
end
