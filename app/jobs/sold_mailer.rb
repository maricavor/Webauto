class SoldMailer
  @queue = :normal
  def self.perform(advert_id)
  advert=Advert.with_deleted.find(advert_id)
  vehicle=advert.vehicle
  vehicle.saved_items.each do |si|
   user=si.user
    if user.sold_alert
      Notifier.vehicle_status_sold(vehicle,user,advert.delete_reason_id).deliver
    end
  end
  end
 end