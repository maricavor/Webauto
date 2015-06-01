class SoldMailer
  @queue = :normal
  def self.perform(advert_id)
  advert=Advert.with_deleted.find(advert_id)
  saved_items=SavedItem.where(:advert_id=>advert_id)
  saved_items.each do |si|
   user=si.user
    if user.sold_alert
      Notifier.vehicle_status_sold(advert,user).deliver
    end
  end
  end
 end