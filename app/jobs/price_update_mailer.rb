class PriceUpdateMailer
  @queue = :normal
  def self.perform(advert_id)
    ActiveRecord::Base.verify_active_connections!
  advert=Advert.find(advert_id)
  vehicle=advert.vehicle
  unless vehicle.price_alert.nil?
  vehicle.saved_items.each do |si|
    user=si.user
    Notifier.vehicle_price_updated(vehicle,user).deliver if user.price_alert
   end
   vehicle.price_alert.destroy!
 end
  end
  
    def self.log(message, method = nil)
      now = Time.now.strftime("%Y-%m-%d %H:%M:%S")
      Rails.logger.info "#{now} %s#%s - #{message}" % [self.name, method]
    end
 end