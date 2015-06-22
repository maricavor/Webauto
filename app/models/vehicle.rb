class Vehicle < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :reg_nr, :advert_id, :make_id, :model_id, :model_spec, :make_model,:bodytype_id, :type_id, :year, :badge, :vin, :registered_at, :bodytype_details, :odometer, :colour_id, :specific_colour, :metallic_colour, :price, :price_vat, :transmission_id, :fueltype_id, :drivetype_id, :climate_control_id, :user_id, :country_id, :origin_id, :registered, :is_active, :inspection_valid_to, :doors, :seats, :description, :popularity, :power_steering, :power_steering_details, :central_locking, :with_remote, :abs, :airbags, :alarm, :alarm_details, :alarm_with_tow_away_protection, :alarm_with_motion_sensor, :alarm_with_two_way_comm, :immobilizer, :anti_skidding, :anti_skidding_details, :stability_control, :stability_control_details, :braking_force_reg, :braking_force_reg_details, :traction_control, :traction_control_details, :third_brake_light, :rain_sensor, :seatbelt_pretightener, :xenon, :xenon_low_beam, :xenon_high_beam, :headlight_washer, :special_light, :fog_lights, :fog_lights_front, :fog_lights_rear, :headlight_range, :extra_lights, :extra_lights_details, :auto_light, :summer_tires, :summer_tires_details, :summer_tires_size, :winter_tires, :winter_tires_details, :winter_tires_size, :all_season_tires, :spike_tires, :light_alloy_wheels, :dust_shields_details, :dust_shields, :light_alloy_wheels_details, :light_alloy_wheels_size, :steering_wheel_adjustment, :steering_wheel_height_and_depth, :steering_wheel_electrical, :steering_wheel_with_memory, :steering_wheel_multifunctional, :steering_wheel_leather, :car_stereo, :car_stereo_details, :car_stereo_cd, :car_stereo_mp3, :car_stereo_usb, :car_stereo_aux, :car_stereo_card, :car_stereo_original, :car_stereo_with_remote, :speakers_count, :subwoofer, :electric_antenna, :cd_changer, :navigation, :computer, :car_phone, :hands_free, :hands_free_details, :gsm, :mats, :textile_mats, :rubber_mats, :velour_mats, :leather_shift_lever, :leather_hand_break, :electrical_seats_with_memory, :electrical_seats_count, :seat_heating_count, :front_armrest, :rear_armrest, :down_folding_back_rest, :electric_mirrors, :heated_mirrors, :folding_mirrors, :mirrors_with_memory, :power_windows, :tinted_windows, :sunroof, :sunroof_details, :cruise_control, :distance_monitoring, :engine_preheating, :engine_preheating_details, :spot_lights, :parking_aid, :parking_aid_front, :parking_aid_rear, :inside_temperature_indicator, :roof_railings, :roof_rack, :outside_temperature_indicator, :front_window_heating, :rear_window_heating, :isolation_net, :luggage_cover, :tow_hitch, :tow_hitch_removable, :tow_hitch_electrical, :other_equipment, :sump_shield, :side_steps, :engine_power, :engine_size, :engine_type, :fueltank, :fuel_cons_city, :fuel_cons_freeway, :fuel_cons_combined, :acceleration, :max_speed, :transmission_details, :net_weight, :gross_weight, :load_capacity, :length, :width, :height, :warranty_valid_to, :service_book, :wrecked, :wrecked_details, :exchange, :exchange_details, :other_info, :gears, :cylinders, :emissions, :state_id, :city_id, :rear_wiper, :trim, :cloth_upholstery, :vinyl_upholstery, :faux_leather_upholstery, :wood_grain, :chrome, :leather_upholstery, :garage_item, :wheelbase, :warranty_km, :service_freq, :service_km, :price_negotiable, :deleted_at, :next_service, :next_service_km, :service_history_id, :owners,:show_reg_nr
  belongs_to :type
  belongs_to :user
  belongs_to :bodytype
  belongs_to :make
  belongs_to :model
  belongs_to :country
  belongs_to :state
  belongs_to :city
  belongs_to :advert
  has_many :comments, :dependent => :destroy
  has_many :price_changes, :dependent => :destroy, :order => [ :created_at ]
  has_many :saved_items
  has_and_belongs_to_many :watchers, :join_table => "vehicle_watchers", :class_name => "User"
  scope :is_dealer, joins(:user).where('users.is_dealer' => true)
  scope :is_private, joins(:user).where('users.is_dealer' => false)
  scope :activated,joins(:advert).where('adverts.activated' => true)
  has_many :pictures, :order => :position
  has_many :users, :through => :saved_items
  has_many :impressions, :dependent => :destroy
  validates :make_id, :presence => true, :on => :update
  validates :type_id, :presence => true, :on => :update
  validates :model_id, :presence => true, :on => :update
  validates :model_spec, :presence => true, :if => :no_model? # Proc.new {|v| v.model_id==0 }
  #validates :reg_nr, uniqueness: true
  validates :registered_at, :presence => true,:on => :update
  validates :engine_power,:presence => true,numericality: { only_integer: true,greater_than: 0},:on => :update
  validates :engine_size,:presence=>true,:on => :update
  #validates :year, :presence => true, numericality: { only_integer: true, greater_than_or_equal_to: 1900, less_than_or_equal_to: Date.today.year }
  #validates :year, format: {with: /(19|20)\d{2}/i, message: "should be a four-digit number"}, :allow_blank => true
  validates :bodytype_id, :presence => true,:on => :update
  validates :transmission_id, :presence => true,:if => Proc.new { |v| v.advert.details? }
  validates :fueltype_id, :presence => true,:on => :update
  validates :odometer, :presence => true,numericality: { only_integer: true},:on => :update
  validates :price, :presence => true,:format => {:with => /\A\d+(?:\.\d{0,2})?\z/}, :numericality => {:greater_than => 0}, :if => Proc.new { |v| v.advert.contact? }
  validates :country_id,:presence => true,:if => Proc.new { |v| v.advert.details? }
  validates :drivetype_id,:presence => true,:if => Proc.new { |v| v.advert.details? }
  validates :doors,:presence => true,numericality: { only_integer: true,greater_than: 0},:if => Proc.new { |v| v.advert.details? }
  validates :seats,:presence => true,numericality: { only_integer: true,greater_than: 0},:if => Proc.new { |v| v.advert.details? }
  validates :colour_id,:presence => true,:on => :update
  validates :state_id,:presence => true,:on=>:update,:if=>:estonian?
  validates :city_id,:presence => true,:on=>:update,:if=>:state?
  validate :description_length,:on=>:update,:if => Proc.new { |v| v.advert.photos? }
  #################
  #is_impressionable #:counter_cache => true, :column_name => :popularity,:unique =>  [:session_hash]
  translates :description, :fallbacks_for_empty_translations => true
  globalize_accessors :locales => [:et, :en], :attributes => [:description]
  searchable :auto_index => true, :auto_remove => true do
    text :description_et,:description_en
    text :make_model, :model_spec, :badge, :wrecked_details, :exchange_details, :bodytype_details, :engine_type, :transmission_details, :power_steering_details, :alarm_details, :anti_skidding_details, :stability_control_details, :braking_force_reg_details, :traction_control_details, :extra_lights_details, :summer_tires_details, :summer_tires_size, :winter_tires_size, :winter_tires_details, :light_alloy_wheels_size, :light_alloy_wheels_details, :car_stereo_details, :hands_free_details, :sunroof_details, :engine_preheating_details, :other_equipment
    integer :odometer
    integer :type_id
    integer :id
    integer :popularity
    integer :bodytype_id
    float :price
    integer :engine_power
    integer :seats
    integer :fueltype_id
    integer :transmission_id
    integer :drivetype_id
    integer :colour_id
    integer :doors
    integer :user_id
    integer :advert_id
    integer :country_id
    integer :climate_control_id
    string :make_model
    time :created_at
    time :registered_at_date
    string :serie_name do
      if model
        model.serie.name if model.serie
      end
    end
    string :make_name do
      make.name if make
    end
    string :model_name do
      model.name if model
    end
    string :state do
      state.name if state
    end
    string :city do
      city.name if city
    end
    boolean :is_dealer do
      user.is_dealer
    end
    boolean :activated do
      advert.activated if advert
    end
    boolean :garage_item
    boolean :power_steering
    boolean :power_windows
    boolean :leather_upholstery
    integer :seat_heating_count
    boolean :navigation
    boolean :central_locking
    boolean :tow_hitch
    boolean :cruise_control
    boolean :light_alloy_wheels
    integer :service_history_id
  end

  def to_param
    if registered_at.present?
      "#{id} #{make_model} #{registered_at_year}".parameterize
    else
      "#{id} #{make_model}".parameterize
    end
  end

  def origin
    Country.find(self.origin_id) if self.origin_id
  end
  
  def final_price
    last_price_change=self.price_changes.last
    if last_price_change.nil?
      return self.price
    else
      if last_price_change.value!=self.price
        return last_price_change.value
      end
    end
    return self.price
  end
  def registered_at_date
   DateTime.parse(self.registered_at) if self.registered_at
  end
  def registered_at_year
    self.registered_at[/(\d{4})/] if self.registered_at
  end
  def engine_power_str
   self.engine_power.present? ? "#{self.engine_power} kW" : "&nbsp;".html_safe 
  end
  def engine_size_str
  self.engine_size.present? ? "#{self.engine_size} L" : "&nbsp;".html_safe
end
  def odometer_str
  self.odometer.present? ? "#{self.odometer} km" : "&nbsp;".html_safe
  end
  def bodytype_str
  self.bodytype ? self.bodytype.name : "&nbsp;".html_safe 
  end
  def fueltype_str
   self.fueltype ? "#{self.fueltype}" : "&nbsp;".html_safe
  end
 
  
  def warranty_km_str
   self.warranty_km.present? ? "#{self.warranty_km} km" : ""
  end
    def service_freq_str
   self.service_freq.present? ? "#{self.service_freq} #{I18n.t("vehicles.show.months")}" : ""
  end
  def service_km_str
   self.service_km.present? ? "#{self.service_km} km" : ""
  end
  def next_service_km_str
self.next_service_km.present? ? "#{self.next_service_km} km" : ""
  end
  def fuel_cons_city_str
   self.fuel_cons_city.present? && self.fuel_cons_city>0 ? "#{self.fuel_cons_city} L/100 km" : ""
  end
  def fuel_cons_freeway_str
    self.fuel_cons_freeway.present? && self.fuel_cons_freeway>0 ? "#{self.fuel_cons_freeway} L/100 km" : ""
  end
  def fuel_cons_combined_str
    self.fuel_cons_combined.present? && self.fuel_cons_combined>0 ? "#{self.fuel_cons_combined} L/100 km" : ""
  end
  def fueltank_str
    self.fueltank.present?  && self.fueltank>0 ? "#{self.fueltank} L" : ""
  end
  def cylinders_str
    self.cylinders>0 ? self.cylinders : ""
  end
   def max_speed_str
    self.max_speed.present? && self.max_speed>0 ? "#{self.max_speed} km/h" : ""
  end
   def acceleration_str
    self.acceleration.present? && self.acceleration>0 ? "#{self.acceleration} s" : ""
  end
   def length_str
    self.length.present? && self.length>0 ? "#{self.length} mm" : ""
  end
   def height_str
    self.height.present? && self.height>0 ? "#{self.height} mm" : ""
  end
   def width_str
    self.width.present? && self.width>0 ? "#{self.width} mm" : ""
  end
     def wheelbase_str
    self.wheelbase.present? && self.wheelbase>0 ? "#{self.wheelbase} mm" : ""
  end
     def gross_weight_str
    self.gross_weight.present? && self.gross_weight>0 ? "#{self.gross_weight} kg" : ""
  end
    def load_capacity_str
    self.load_capacity.present? && self.load_capacity>0 ? "#{self.load_capacity} kg" : ""
  end
    def net_weight_str
    self.net_weight.present? && self.net_weight>0 ? "#{self.net_weight} kg" : ""
  end
  def origin_str
   self.origin ? self.origin.name : ""
  end
  def doors_str
  self.doors>0 ? self.doors : ""
  end
  def origin_name
    self.origin.name if self.origin
  end
  def seats_str
   self.seats>0 ? self.seats : ""
  end
  def owners_str
   self.owners.present? && self.owners>0 ? self.owners : ""
  end
  def self.lalala
    Rails.logger.info "Rescue job"
  end
 
  def odometer_str
    self.odometer.to_s + " km"
  end
  def climate_control_str
    self.climate_control ? "#{self.climate_control}" : "&nbsp;".html_safe
  end
  def transmission_str
    t=""
    t+=self.transmission if self.transmission
    #t+= " ("+self.gears.to_s + " gears)" if self.gears>0
    #t=="" ? "&nbsp;".html_safe : t
  end
  
  def model_name
    if model
      self.model.name
    else
      self.model_spec
    end
  end
    def make_name
    if make
      self.make.name
    else
      ""
    end
  end
  def save_price

    self.price_changes.create!(:value=>self.price)
    self.advert.update_attributes(:price=>self.price)

  end
  
  def price_diff
    value=0
    pc=self.price_changes
    first_value=pc.first.value
    if pc.size > 1
    last_value=pc.last.value
    if last_value<first_value
    value = (Float(first_value - last_value) / first_value * 100).ceil
    else
    value = -(Float(last_value - first_value) / last_value * 100).ceil
    end
    end
    return value
  end

  def name
    "#{self.registered_at.strftime('%Y')} #{self.make.name} #{self.model_name} #{self.badge}"
  end
  def previous_price
   pc=self.price_changes.last(2)
   if pc.size>1
    pc[0].value
  else
    nil
  end
  end
  def location
    location=""
    location +=self.country.name if self.country
    location +="/"+self.city.name if self.city
    location
  end

  def colour
    I18n.t('colours').find { |c| c["id"]==self.colour_id }["name"] if self.colour_id.present?
  end

  def fueltype
    I18n.t('fueltypes').find { |c| c["id"]==self.fueltype_id }["name"] if self.fueltype_id.present?
  end

  def service_history
    I18n.t('service_histories').find { |c| c["id"]==self.service_history_id }["name"] if self.service_history_id.present?
  end

  def climate_control
    I18n.t('climate_controls').find { |c| c["id"]==self.climate_control_id }["name"] if self.climate_control_id.present?
  end

  def drivetype
    I18n.t('drivetypes').find { |c| c["id"]==self.drivetype_id }["name"] if self.drivetype_id.present?
  end

  def transmission
    I18n.t('transmissions').find { |c| c["id"]==self.transmission_id }["name"] if self.transmission_id.present?
  end

  def impressionist_count(options={})
    # Uses these options as defaults unless overridden in options hash
    options.reverse_merge!(:filter => :request_hash, :start_date => nil, :end_date => Time.now)

    # If a start_date is provided, finds impressions between then and the end_date. Otherwise returns all impressions
    imps = options[:start_date].blank? ? self.impressions : self.impressions.where("created_at >= ? and created_at <= ?", options[:start_date], options[:end_date])

    # Count all distinct impressions unless the :all filter is provided.
    distinct = options[:filter] != :all
    distinct ? imps.count(options[:filter], :distinct => true) : imps.count

  end


  def no_model?
    self.model_id==0
  end


  private
  def estonian?
    self.advert.details? && self.country_id==8
  end
  def state?
    self.advert.details? && self.state_id!=nil
  end
  def generate_ad_number
    record = true
    while record
      random = "WA#{Array.new(9) { rand(9) }.join}"
      record = Vehicle.find(:first, :conditions => ["ad_number = ?", random])
    end
    self.ad_number = random
  end


  def generate_keywords
    self.keywords=""
    specs=[:car_stereo, :car_stereo_details, :car_stereo_cd, :car_stereo_mp3, :car_stereo_usb, :car_stereo_aux, :car_stereo_card, :car_stereo_original, :car_stereo_with_remote]
    specs.each do |spec|
      self.keywords << I18n.t(serialize(self, spec))
    end
  end

  def serialize(object, attr)
    #"#{attr}: #{object.send(attr)}"
    "#{attr}"
  end

  def description_length
    locales=I18n.available_locales.map {|l| l.to_s} 
    locales.each do |loc| 
      description=self.send("description_"+loc)
      if description.present? 
    if description.length<10
      errors.add(:description,'is too short')
      return
    end
     if description.length>1000
      errors.add(:description,'is too long')
      return
    end
    end
    end 

    
    
  end
end