class PriceChange < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :value,  :vehicle_id,:deleted_at
  attr_accessible :value, :vehicle_id, :as => :admin
  belongs_to :vehicle
  #validates :value, :format => {:with => /\A\d+(?:\.\d{0,2})?\z/}, :numericality => {:greater_than => 0}
end