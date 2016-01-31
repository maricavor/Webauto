class VehicleWatcher < ActiveRecord::Base
  attr_accessible :user_id, :vehicle_id
  belongs_to :user
  
end
