class PriceUpdateMailer
  @queue = :normal
  def self.perform(advert_id)
  advert=Advert.find(advert_id)
  if advert.activated
  saved_items=SavedItem.where(:advert_id=>advert_id)
  saved_items.each do |si|
   user=si.user
    if user.price_alert
      log("Sent mail to "+user.email)
      Notifier.vehicle_price_updated(advert,user).deliver
    end
   end
  end
  end
    def self.log(message, method = nil)
      now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      Rails.logger.info "#{now} %s#%s - #{message}" % [self.name, method]
    end
 end