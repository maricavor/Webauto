class PriceAlert < ActiveRecord::Base
  attr_accessible :vehicle_id
  belongs_to :vehicle

end
