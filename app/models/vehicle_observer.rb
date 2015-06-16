class VehicleObserver < ActiveRecord::Observer
  def after_update(vehicle)
    
    update_price_and_inform(vehicle) if vehicle.advert.contact_saved
  end
  def after_create(vehicle)
    vehicle.watchers << vehicle.user
  end

  private

  def update_price_and_inform(v)
   last_price_change=v.price_changes.last
    if last_price_change.nil?
      v.save_price
    else
      if last_price_change.value!=v.price
       v.save_price
       Resque.enqueue(PriceUpdateMailer, v.advert_id)
      end
    end
  end

  

end