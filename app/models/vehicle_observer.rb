class VehicleObserver < ActiveRecord::Observer
  def after_update(vehicle)
    update_price_and_inform(vehicle) if vehicle.price_changed?
  end
  def after_create(vehicle)
    unless vehicle.advert_id.nil?
    vehicle.watchers << vehicle.user
  end
  end

  private

  def update_price_and_inform(v)
   last_price_change=v.price_changes.last
    if last_price_change.nil?
      v.save_price
    else
      if last_price_change.value!=v.price 
       v.save_price
       Resque.enqueue(PriceUpdateMailer, v.id)
      end
    end
  end

  

end