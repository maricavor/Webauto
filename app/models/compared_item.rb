class ComparedItem < ActiveRecord::Base
  MAX_ITEMS=4
  attr_accessible :user_id, :vehicle_id,:ip_address,:session_hash
  belongs_to :user
  belongs_to :vehicle
  validates :vehicle_id, :uniqueness => { :scope => :session_hash }
  validate :quantity_of_items

  def vehicle
    Vehicle.unscoped {super}
  end

  private

  def quantity_of_items
   	compared_items=ComparedItem.where(:session_hash=>session_hash)
      if compared_items.size >= ComparedItem::MAX_ITEMS
         errors[:base] << "You cannot compare more than #{MAX_ITEMS} vehicles."
      end
  end
end
