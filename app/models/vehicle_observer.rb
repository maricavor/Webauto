class VehicleObserver < ActiveRecord::Observer
  def after_update(vehicle)
    update_last_price(vehicle) if vehicle.price_changed?
  end
  def after_create(vehicle)
    
    unless vehicle.advert_id.nil?
    vehicle.watchers << vehicle.user 
    
    end
   
  end
  def after_save(vehicle)
   
    update_make_model(vehicle)
 
  end

  private

  def update_last_price(v)
   last_price_change=v.price_changes.last
    if last_price_change.nil?
      v.save_price
    else
      if last_price_change.value!=v.price 
       v.save_price
       #Resque.enqueue(PriceUpdateMailer, v.id)
      end
    end
  end

  def update_make_model(v)
    make_model=v.make_name+" "+v.model_name
    v.update_column(:make_model,make_model) 
    v.update_column(:model_spec,nil) if v.model_id!=0
    v.advert.update_column(:make_model,make_model) if v.advert
  end

end