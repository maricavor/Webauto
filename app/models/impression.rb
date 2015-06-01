class Impression < ActiveRecord::Base
  attr_accessible :action_name, :controller_name, :ip_address, :referrer, :request_hash, :session_hash, :user_id, :vehicle_id
  belongs_to :vehicle
  belongs_to :user
  scope :from, ->(duration){ where('created_at > ?', Time.zone.now - duration ) }
end
