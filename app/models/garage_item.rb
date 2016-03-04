class GarageItem < ActiveRecord::Base
  MAX_ITEMS=5
  attr_accessible :user_id, :vehicle_id,:ownership_id,:advert_id
  belongs_to :user
  belongs_to :vehicle
  belongs_to :advert
  validates :vehicle_id, :uniqueness => true
  validate :quantity_of_items,:on=>:create
  validates :ownership_id, :presence => true
  
  def vehicle
   Vehicle.unscoped { super }
 end
 def advert
  Advert.unscoped { super }
end
  def to_param
    if self.vehicle.registered_at.present?
      "#{self.id} #{self.vehicle.make_model} #{self.vehicle.registered_at_year}".parameterize
    else
      "#{self.id} #{self.vehicle.make_model}".parameterize
    end
  end
  def ownership
    I18n.t('ownership').find { |a| a["id"]==self.ownership_id }["name"] if self.ownership_id.present?
  end
  private
  def quantity_of_items
      if self.user.garage_items.count>=GarageItem::MAX_ITEMS
         errors[:base] << "You cannot add more than #{MAX_ITEMS} vehicles."
         return
      end
  end
end
