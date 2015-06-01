class CarsController < VehiclesController
  TYPE=1
  before_filter :only=>[:index] do |controller|
    controller.get_index_vehicles(TYPE)
  end
  before_filter :only=>[:index,:search] do |controller|
    controller.get_property_records(TYPE)
  end
  before_filter :except=>[:show,:destroy] do |controller|
    controller.init_gon(TYPE)
  end

  def set_current_type
    session[:type_id] =  TYPE
  end


end