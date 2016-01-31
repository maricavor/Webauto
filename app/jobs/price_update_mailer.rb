class PriceUpdateMailer
  @queue = :normal
  def self.perform(vehicle_id)
  vehicle=Vehicle.find(vehicle_id)
  saved_items=SavedItem.where(vehicle_id: vehicle_id)
  saved_items.each do |si|
   user=si.user
    if user.price_alert
      log("Sent mail to "+user.email)
      Notifier.vehicle_price_updated(vehicle,user).deliver
    end
   end

  end
    def self.log(message, method = nil)
      now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      Rails.logger.info "#{now} %s#%s - #{message}" % [self.name, method]
    end
 end