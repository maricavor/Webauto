# encoding: UTF-8
namespace :create do
  task :cars => :environment do
    require 'nokogiri'
    require 'open-uri'
    url="http://www.auto24.ee/kasutatud/nimekiri.php?bn=2&a=101102&f1=2005&bi=EUR&ae=2&af=200&ag=1&otsi=otsi&ak=600"
    doc = Nokogiri::HTML(open(url))
    #create_car("http://eng.auto24.ee/used/1549229")
    doc.css("table.search-list a.small-image").each do |item|

      create_car("http://eng.auto24.ee"+item.attr('href').to_s)
    end
  end
  task :colour_translations=>:environment do
    I18n.locale = :et
    colours=Colour.all
    colours.each do |c|
      c.update_attribute(:name, c.name)

    end
  end
   task :country_translations=>:environment do
    I18n.locale = :et
    countries=Country.all
    countries.each do |c|
    c.update_attribute(:name, c.name)
    end
  end
  task :registered=>:environment do
    vehicles=Vehicle.with_deleted.all
    vehicles.each do |v|
      random_year=Random.new.rand(2015..2017)
      random_month=Random.new.rand(1..12)
      if v.advert
      v.update_attribute(:inspection_valid_to, random_month.to_s + "/" + random_year.to_s)
      end
    end
  end
  task :car => :environment do
    require 'nokogiri'
    require 'open-uri'

    #id=ENV['id']
    #url = "http://eng.auto24.ee/used/"+id.to_s
    url="http://eng.auto24.ee/kasutatud/auto.php?id=1664264"
    create_car(url)

  end

  def create_car(url)

    id=url.split('/').last.to_i
    doc = Nokogiri::HTML(open(url))

    unless Vehicle.exists?(auto24_id: id)

      vehicle=Vehicle.new
      vehicle.auto24_id=id
      #doc.css("div.img-container a").each do |t|
      #puts a.at_css("img").attr('src').split('/').last.gsub(/[^0-9]/, '').to_i
      #puts t.text
      #end

      picture=Picture.new


      title=doc.at_css("h1.commonSubtitle").text

      a=title.split
      make=Make.find(:first, :conditions => [ "name = ?", a[0]])
      vehicle.make=make
      #puts vehicle.make.name
      m=make.models.find(:first, :conditions => [ "name = ?", a[1]]) if make
      if m.nil?
        vehicle.model=make.models.find(:first, :conditions => [ "name = ?", a[1]+' '+a[2]]) if make
      else
        vehicle.model=m
      end
      #puts vehicle.model_name

      doc.css("table.main-data tr").each do |item|
        label=item.at_css(".label").text
        field=item.at_css(".field").text

        set_type(vehicle,field) if label.downcase.include? "type"
        set_bodytype(vehicle,field) if label.downcase.include? "bodytype"
        set_registration(vehicle,field) if label.downcase.include? "reg"
        if label.downcase.include? "engine"
          set_engine(vehicle,field)
          ff=field.downcase.gsub(/\(|\)/, '')
          ff=ff.sub(' kw','kw')
          make_model=title.downcase.sub(ff, '')
          Make.all.each do |mk|
            if make_model.include? mk.name.downcase
              vehicle.make=mk
              make_model=make_model.sub(mk.name.downcase,'')
            end
          end

          unless vehicle.make.nil?
            vehicle.make.models.each do |md|
              vehicle.model=md if make_model.include? md.name.downcase
            end
            vehicle.model_spec=make_model if vehicle.model.nil?
          end


        end
        set_fuel(vehicle,field) if label.downcase.include? "fuel"
        set_mileage(vehicle,field) if label.downcase.include? "mileage"
        set_drive(vehicle,field) if label.downcase.include? "drive"
        set_transmission(vehicle,field) if label.downcase.include? "transmission"
        set_colour(vehicle,field) if label.downcase.include? "color"
        #set_vin(vehicle,field) if label.downcase.include? "vin"
        set_price(vehicle,field) if label.downcase.gsub(/[\:]/, '') == "price"
        set_bargain_price(vehicle,field) if label.downcase.include? "bargain"
        #puts label.to_s+" "+field.to_s



      end
      doc.css("div.equipment ul li.item").each do |ul|
        eq=ul.text

        if eq.downcase.include? "power steering"
          vehicle.power_steering=true
          vehicle.power_steering_details=eq[0..eq.downcase.index("power")-2]
        end

        if eq.downcase.include? "central locking"
          vehicle.central_locking=true
          vehicle.with_remote=true if eq.downcase.include? "remote control"
        end
        vehicle.abs=true if eq.include? "abs brakes"
        if eq.downcase.include? "airbag"

          vehicle.airbags=eq.downcase.scan(/\d+/).first.to_i
        end
        if eq.downcase.include? "anti-theft"
          vehicle.alarm=true
          vehicle.alarm_details=eq[0..eq.downcase.index("anti-theft")-2]
          vehicle.alarm_with_tow_away_protection=true if eq.downcase.include? "tow-away"
          vehicle.alarm_with_motion_sensor=true if eq.downcase.include? "motion sensor"
          vehicle.alarm_with_two_way_comm=true if eq.downcase.include? "two way communication"
        end
        if eq.downcase.include? "immobilizer"
          vehicle.immobilizer=true

        end
        if eq.downcase.include? "anti skidding"
          vehicle.anti_skidding=true
          vehicle.anti_skidding_details=eq.downcase.sub("anti skidding",'')
        end
        if eq.downcase.include? "stability control"
          vehicle.stability_control=true
          vehicle.stability_control_details=eq.downcase.sub("stability control",'')
        end
        if eq.downcase.include? "braking force regulator"
          vehicle.braking_force_reg=true
          vehicle.braking_force_reg_details=eq.downcase.sub("braking force regulator",'')
        end
        if eq.downcase.include? "traction control"
          vehicle.traction_control=true
          vehicle.traction_control_details=eq.downcase.sub("traction control",'')
        end
        vehicle.third_brake_light=true if eq.downcase.include? "third brake light"
        vehicle.rain_sensor=true if eq.downcase.include? "rain sensor"
        vehicle.seatbelt_pretightener=true if eq.downcase.include? "seatbelt pre-tighteners"

        vehicle.climate_control_id=1 if eq.downcase.include? "climate control"
        vehicle.climate_control_id=2 if eq.downcase.include? "air conditioner"

        if eq.downcase.include? "power windows"
          vehicle.power_windows=true
          #vehicle.power_windows_count=eq.downcase.scan(/\d+/).first.to_i
        end
        if eq.downcase.include? "electrically adjustable mirrors"
          vehicle.electric_mirrors=true
          vehicle.heated_mirrors=true if eq.downcase.include? "heated"
          vehicle.folding_mirrors=true if eq.downcase.include? "folding"
          vehicle.mirrors_with_memory=true if eq.downcase.include? "memory"
        end
        #xxx sunroof (glass, electric)
        if eq.downcase.include? "sunroof"
          vehicle.sunroof=true
          #vehicle.sunroof_details=eq[0..eq.downcase.index("sunroof")-2]
        end
        # cruise control (monitoring the distance to vehicle in front)
        if eq.downcase.include? "cruise control"
          vehicle.cruise_control=true
          vehicle.distance_monitoring=true if eq.downcase.include? "monitoring"
        end
        # parking aid (front, rear)
        if eq.downcase.include? "parking aid"
          vehicle.parking_aid=true
          vehicle.parking_aid_front=true if eq.downcase.include? "front"
          vehicle.parking_aid_rear=true if eq.downcase.include? "rear"
        end
        # xxx engine pre-heating
        if eq.downcase.include? "pre-heating"
          vehicle.engine_preheating=true
          vehicle.engine_preheating_details=eq.downcase.sub("engine pre-heating",'')
        end
        # tinted windows
        vehicle.tinted_windows=true if eq.downcase.include? "tinted windows"
        # 2x mirrors in sunshields (enlighted)
        #if eq.downcase.include? "mirrors in sunshields"
        #  vehicle.mirrors_in_sunshields=true
        #  vehicle.mirrors_in_sunshields_count=eq.downcase.scan(/\d+/).first.to_i
        #  vehicle.mirrors_in_sunshields_enlighted=true if eq.downcase.include? "enlighted"
        #end
        # spot lights
        vehicle.spot_lights=true if eq.downcase.include? "spot lights"
        # internal temperature indicator
        vehicle.inside_temperature_indicator=true if eq.downcase.include? "internal temperature"
        # xxx leather interior
        if eq.downcase.include? "leather interior"
          vehicle.leather_interior=true
          vehicle.leather_interior_details=eq.downcase.sub("leather interior",'')
        end
        # xxx half-leather padding
        if eq.downcase.include? "half-leather"
          vehicle.half_leather_padding=true
          vehicle.half_leather_padding_details=eq.downcase.sub("half-leather",'')
        end
        # xxx velour padding
        if eq.downcase.include? "velour padding"
          vehicle.velour_padding=true
          vehicle.velour_padding_details=eq[0..eq.downcase.index("velour padding")-2]
        end
        # xxx textile upholstery
        if eq.downcase.include? "textile upholstery"
          vehicle.textile_upholstery=true
          vehicle.textile_upholstery_details=eq[0..eq.downcase.index("textile upholstery")-2]
        end
        # 2x electrically adjustable seats (with memory)
        #if eq.downcase.include? "adjustable seats"
        #  vehicle.electrical_seats=true
        #  vehicle.electrical_seats_count=eq.downcase.scan(/\d+/).first.to_i
        #  vehicle.electrical_seats_with_memory=true if eq.downcase.include? "memory"
        #end
        # 2x seat heating
        #if eq.downcase.include? "seat heating"
        #  vehicle.seat_heating=true
        #  vehicle.seat_heating_count=eq.downcase.scan(/\d+/).first.to_i
        #end
        # down folding back rest
        vehicle.down_folding_back_rest=true if eq.downcase.include? "down folding"
        # leather steering wheel
        vehicle.steering_wheel_leather=true if eq.downcase.include? "leather steering"
        # multifunctional steering wheel
        vehicle.steering_wheel_multifunctional=true if eq.downcase.include? "multifunctional steering"
        # steering wheel adjustment (height and depth, electrical, with memory)
        if eq.downcase.include? "wheel adjustment"
          vehicle.steering_wheel_adjustment=true
          vehicle.steering_wheel_height_and_depth=true if eq.downcase.include? "height and depth"
          vehicle.steering_wheel_electrical=true if eq.downcase.include? "electrical"
          vehicle.steering_wheel_with_memory=true if eq.downcase.include? "memory"
        end
        # leather shift lever
        vehicle.leather_shift_lever=true if eq.downcase.include? "leather shift"
        # leather-coated hand brake handle
        vehicle.leather_hand_break=true if eq.downcase.include? "leather-coated hand"
        # front armrest (with compartment)
        if eq.downcase.include? "front armrest"
          vehicle.front_armrest=true
          #vehicle.front_armrest_with_compartment=true if eq.downcase.include? "compartment"
        end
        # rear armrest (with compartment)
        #if eq.downcase.include? "rear armrest"
        # vehicle.rear_armrest=true
        #vehicle.rear_armrest_with_compartment=true if eq.downcase.include? "compartment"
        #end
        # xxx fine laths inside saloon (wood inlay)
        if eq.downcase.include? "fine laths"
          # vehicle.fine_laths=true
          #vehicle.fine_laths_details=eq[0..eq.downcase.index("fine laths")-2]
          #vehicle.fine_laths_wood_inlay=true if eq.downcase.include? "wood"
        end
        # mats (interior textile mats, interior rubber mats, interior velour mats)
        if eq.downcase.include? "mats"
          vehicle.mats=true
          vehicle.textile_mats=true if eq.downcase.include? "textile"
          vehicle.rubber_mats=true if eq.downcase.include? "rubber"
          vehicle.velour_mats=true if eq.downcase.include? "velour"
        end
        # xxx car stereo (cd, mp3, with usb interface, xxx, original, with remote control)
        if eq.downcase.include? "car stereo"
          vehicle.car_stereo=true
          vehicle.car_stereo_details=eq[0..eq.downcase.index("car stereo")-2]
          vehicle.car_stereo_cd=true if eq.downcase.include? "cd"
          vehicle.car_stereo_mp3=true if eq.downcase.include? "mp3"
          vehicle.car_stereo_usb=true if eq.downcase.include? "usb"
          vehicle.car_stereo_card=true if eq.downcase.include? "memory card"
          vehicle.car_stereo_original=true if eq.downcase.include? "original"
          vehicle.car_stereo_with_remote=true if eq.downcase.include? "remote"
        end
        # xxx stereo amplifier
        #if eq.downcase.include? "stereo amplifier"
        # vehicle.stereo_amplifier=true
        # vehicle.stereo_amplifier_details=eq[0..eq.downcase.index("stereo amplifier")-2]
        #end
        # xxx speakers
        if eq.downcase.include? "speakers"
          #vehicle.speakers=true
          #vehicle.speakers_details=eq[0..eq.downcase.index("speakers")-2]
        end
        # xxx subwoofer
        if eq.downcase.include? "subwoofer"
          vehicle.subwoofer=true
          #vehicle.subwoofer_details=eq[0..eq.downcase.index("subwoofer")-2]
        end
        # xxx cd changer
        vehicle.cd_changer=true if eq.downcase.include? "cd changer"
        # electric antenna
        vehicle.electric_antenna=true if eq.downcase.include? "electric antenna"
        # navigation system (with map, with voice recognition)
        vehicle.navigation=true if eq.downcase.include? "navigation"
        # computer
        vehicle.computer=true if eq.downcase.include? "computer"
        # xxx car phone
        vehicle.car_phone=true if eq.downcase.include? "car phone"
        # xxx hands free
        vehicle.hands_free=true if eq.downcase.include? "hands free"
        # gsm antenna
        vehicle.gsm=true if eq.downcase.include? "gsm"
        # xxx summer tires
        if eq.downcase.include? "summer tires"
          vehicle.summer_tires=true
          vehicle.summer_tires_details=eq[0..eq.downcase.index("summer tires")-2]
        end
        # xxx winter tires (all season tires, spike tires)
        if eq.downcase.include? "winter tires"
          vehicle.winter_tires=true
          vehicle.winter_tires_details=eq[0..eq.downcase.index("winter tires")-2]
          vehicle.all_season_tires=true if eq.downcase.include? "all season"
          vehicle.spike_tires=true if eq.downcase.include? "spike"
        end
        # light alloy wheels (16, originaal, xxx)
        if eq.downcase.include? "light alloy"
          vehicle.light_alloy_wheels=true
          #vehicle.light_alloy_wheels_details=eq[eq.downcase.index("(")+1..eq.downcase.index(")")-1]
        end
        # xxx dust shields
        if eq.downcase.include? "dust shields"
          vehicle.dust_shields=true
          # vehicle.dust_shields_details=eq[0..eq.downcase.index("dust shields")-2]
        end
        # xenon headlight (low beam, high beam)
        vehicle.xenon=true if eq.downcase.include? "xenon"
        # headlight washers
        vehicle.headlight_washer=true if eq.downcase.include? "headlight washer"
        # special light switch-dim-dip-light
        vehicle.special_light=true if eq.downcase.include? "special light"
        # fog lights (front, rear)
        if eq.downcase.include? "fog lights"
          vehicle.fog_lights=true
          vehicle.fog_lights_front=true if eq.downcase.include? "front"
          vehicle.fog_lights_rear=true if eq.downcase.include? "rear"
        end
        # headlight range adjustment
        vehicle.headlight_range=true if eq.downcase.include? "headlight range"
        # xxx extra lights
        if eq.downcase.include? "extra lights"
          vehicle.extra_lights=true
          vehicle.extra_lights_details=eq[0..eq.downcase.index("extra lights")-2]
        end
        # sump shield
        vehicle.sump_shield=true if eq.downcase.include? "sump shield"
        # side steps
        vehicle.side_steps=true if eq.downcase.include? "side steps"
        # xxx roof railings
        vehicle.roof_railings=true if eq.downcase.include? "roof railings"
        # xxx roof rack
        vehicle.roof_rack=true if eq.downcase.include? "roof rack"
        # outside temperature display
        vehicle.outside_temperature_indicator=true if eq.downcase.include? "outside temperature"
        # front window heating
        vehicle.front_window_heating=true if eq.downcase.include? "front window heating"
        # rear window heating
        vehicle.rear_window_heating=true if eq.downcase.include? "rear window heating"
        # saloon and luggage department isolation net
        vehicle.isolation_net=true if eq.downcase.include? "isolation net"
        # luggage cover
        vehicle.luggage_cover=true if eq.downcase.include? "luggage cover"
        # luggage net
        vehicle.luggage_net=true if eq.downcase.include? "luggage net"
        # rear window cleaner
        vehicle.rear_window_cleaner=true if eq.downcase.include? "window cleaner"
        # tow hitch (removable)
        if eq.downcase.include? "tow hitch"
          vehicle.tow_hitch=true
          vehicle.tow_hitch_removable=true if eq.downcase.include? "removable"
        end
      end

      doc.css("div.tech-data table tr").each do |item|
        label=item.at_css(".label").text
        value=item.at_css(".value").text
        # puts label.to_s+" "+value.to_s

        # seats: 5
        # number of doors: 5
        # length: 4615 mm
        # width: 1785 mm
        # height: 1710 mm
        # base curb weight: 1597 kg
        # gross weight: 2020 kg
        # load carring capacity: 423 kg
        # power: 110 kW
        # max speed: 200 km/h
        # acceleration 0-100 km/h: 10 s
        # fuel: petrol
        # fuel tank: 60 l
        # fuel consumption in a city: 10 l/100 km
        # fuel consumption on a freeway: 8 l/100 km
        # fuel consumption average: 9 l/100 km

        vehicle.seats=value.to_i if label.downcase.include? "seats"
        vehicle.doors=value.to_i if label.downcase.include? "doors"
        vehicle.length=value.scan(/\d+/).first.to_i if label.downcase.include? "length"
        vehicle.width=value.scan(/\d+/).first.to_i if label.downcase.include? "width"
        vehicle.height=value.scan(/\d+/).first.to_i if label.downcase.include? "height"
        vehicle.net_weight=value.scan(/\d+/).first.to_i if label.downcase.include? "base curb"
        vehicle.gross_weight=value.scan(/\d+/).first.to_i if label.downcase.include? "gross"
        vehicle.load_capacity=value.scan(/\d+/).first.to_i if label.downcase.include? "load"
        vehicle.engine_power=value.scan(/\d+/).first.to_i if label.downcase.include? "power"
        vehicle.max_speed=value.scan(/\d+/).first.to_i if label.downcase.include? "speed"

        vehicle.acceleration=value.split(' ')[0] if label.downcase.include? "acceleration"
        vehicle.fueltank=value.split(' ')[0] if label.downcase.include? "fuel tank"
        vehicle.fuel_cons_city=value.split(' ')[0] if label.downcase.include? "city"
        vehicle.fuel_cons_freeway=value.split(' ')[0] if label.downcase.include? "freeway"
        vehicle.fuel_cons_combined=value.split(' ')[0] if label.downcase.include? "average"
      end

      title=doc.css("h2.commonSubtitle").each do |item|
        if item.text=="Other information"
          res=[]
          el=item.next_element.to_s
          el.scan(/<br><br>/) do |c|
            res << [c, $~.offset(0)[0]]
          end

          #vehicle.other_info=el[res.first[1]..-1].gsub!(/(<[^>]*>)|\n|\t/s) {''} if res.size>0
          a=el.gsub(/\,|<br>|<br\/>/, '*')
          puts a
          arr=a.split('*')

          arr.each do |txt|
            #if txt.downcase.include? "inspection"
            #  dat=Date.strptime(txt.scan(/\d+\.\d+/).first, "%m.%Y")
            # vehicle.inspection_valid_to=dat if dat
            #end
            if txt.downcase.include? "registered in estonia"

              vehicle.registered=true
            end
            #if txt.downcase.include? "warranty"
            # dat=Date.strptime(txt.scan(/\d+\.\d+/).first, "%m.%Y")
            # vehicle.warranty_valid_to=dat if dat

            #end
            if txt.downcase.include? "bought from"
              country=Country.find_by_name(txt[txt.downcase.index(":")+2..-1])

              vehicle.origin_id=country.id if country
            end
            if txt.downcase.include? "location of a vehicle"
              country=Country.find_by_name(txt[txt.downcase.index(":")+2..-1])
              #region=Region.find_by_name(txt[txt.downcase.index(":")+2..-1])
              vehicle.country_id=country.id if country
              #vehicle.region_id=region.id if region
            end
            if txt.downcase.include? "vehicle exchange"

              vehicle.exchange=true
              #vehicle.exchange_details=txt[txt.downcase.index(":")+2..-1]
            end
            if txt.downcase.include? "wrecked"

              vehicle.wrecked=true
              #vehicle.wrecked_details=txt[txt.downcase.index("(")+1..txt.downcase.index(")")-1]
            end




          end
        end
      end
      vehicle.user_id=1
      puts vehicle.to_yaml

      if vehicle.save

        if doc.css("div.img-container a").at_css("img")
          picture.vehicle_id=vehicle.id
          picture.remote_file_url=doc.css("div.img-container a").at_css("img").attr('src')
          picture.save!
        end
      end
    else
      puts "Already exists!"
    end
  end
  #

  # Honda
  # CR-V
  # Type: SUV
  # Initial reg: 09/2005
  # Engine: 2.0 RD8 (110 kW)
  # Fuel: petrol
  # Mileage: 103,000 km ┬╖ service book
  # Drive: four-wheel drive
  # Transmission: automatic
  # Color: beige met.
  #   Vin:
  #   Price: EUR┬а8000EEK┬а125,172.80VAT 0% (no VAT accrue)
  # xxx power steering
  # central locking (with remote control)
  # abs brakes
  # 3x airbag
  # defa auto security anti-theft alarm system (with tow-away protection, with interior motion sensor, two way communication)
  # xxx immobilizer
  # xxx anti skidding
  # xxx stability control
  # xxx braking force regulator
  # xxx traction control
  # third brake light
  # rain sensor
  # seatbelt pre-tighteners on front seats
  # climate control
  # 4x power windows
  # electrically adjustable mirrors (heated mirrors, folding, with memory)
  # xxx sunroof (glass, electric)
  # cruise control (monitoring the distance to vehicle in front)
  # parking aid (front, rear)
  # xxx engine pre-heating
  # tinted windows
  # 2x mirrors in sunshields (enlighted)
  # spot lights
  # internal temperature indicator

  # xxx leather interior
  # xxx half-leather padding
  # xxx velour padding
  # xxx textile upholstery
  # 2x electrically adjustable seats (with memory)
  # 2x seat heating
  # down folding back rest
  # leather steering wheel
  # multifunctional steering wheel
  # steering wheel adjustment (height and depth, electrical, with memory)
  # leather shift lever
  # leather-coated hand brake handle
  # front armrest (with compartment)
  # rear armrest (with compartment)
  # xxx fine laths inside saloon (wood inlay)
  # mats (interior textile mats, interior rubber mats, interior velour mats)
  # xxx car stereo (cd, mp3, with usb interface, xxx, original, with remote control)
  # xxx stereo amplifier
  # xxx speakers
  # xxx subwoofer
  # xxx cd changer
  # electric antenna
  # navigation system (with map, with voice recognition)
  # computer
  # xxx car phone
  # xxx hands free
  # gsm antenna
  # xxx summer tires
  # xxx winter tires (all season tires, spike tires)
  # light alloy wheels (16, originaal, xxx)
  # xxx dust shields
  # xenon headlight (low beam, high beam)
  # headlight washers
  # special light switch-dim-dip-light
  # fog lights (front, rear)
  # headlight range adjustment
  # xxx extra lights
  # sump shield
  # side steps
  # xxx roof railings
  # xxx roof rack
  # outside temperature display
  # front window heating
  # rear window heating
  # saloon and luggage department isolation net
  # luggage cover
  # luggage net
  # rear window cleaner
  # tow hitch (removable)

  def set_type(v,f)
    if f=="SUV" || f.include?("car") || f.include?("commercial")
      v.type_id=1
    end
    v.bodytype_id=3 if f=="SUV"
  end
  def set_bodytype(v,f)
    if v.bodytype_id.nil?
      if f=="touring"
        v.bodytype_id=4
      elsif f=="minivan"
        v.bodytype_id=9
      elsif f=="cabriolet"
        v.bodytype_id=6
      elsif f=="pickup"
        v.bodytype_id=5
      else
        v.bodytype=Bodytype.find(:first, :conditions => [ "name = ?", f.capitalize])
      end
    end
  end
  def set_registration(v,f)
    if f.include? '/'
      dat=Date.strptime(f, "%m/%Y")
    else
      dat=Date.strptime(f, "%Y")
    end
    v.registered_at=dat if dat
  end
  def set_engine(v,f)
    unless f==''
      if f.match(/(.+) \((.+)\)/)
        v.engine_size=BigDecimal.new(f.match(/(.+) \((.+)\)/).to_a.flatten[1])

        v.engine_power=f.match(/(.+) \((.+)\)/).to_a.flatten[2].gsub(/[^0-9]/, '').to_i
      elsif f.match(/\((.+)\)/)
        v.engine_power=f.gsub(/[\(\)]/, '').to_i
      elsif f.match(/(.+)/)
        v.engine_size=BigDecimal.new(f)
      else

      end

    end
  end
  def set_fuel(v,f)
    v.fueltype=Fueltype.find(:first, :conditions => [ "name = ?", f.titleize])
  end
  def set_mileage(v,f)
    o=f.gsub(/[^0-9]/, '')
    v.odometer=o.to_i unless o.empty?
    v.service_book=true if f.include?("service")
  end
  def set_drive(v,f)
    v.drivetype=Drivetype.find(:first, :conditions => [ "name = ?", f.titleize])

  end
  def set_transmission(v,f)
    unless f.empty?
      a=f.split
      v.transmission=Transmission.find(:first, :conditions => [ "name = ?", a[0].titleize])

      v.transmission_details=f[f.downcase.index("(")+1..f.downcase.index(")")-1] if f.include? "("
    end
  end
  def set_vin(v,f)
    v.vin=f unless f.empty?

  end
  def set_colour(v,f)
    unless f==''
      col=f.split(' ')
      c=Colour.find(:first, :conditions => [ "name = ?", col[0].titleize])
      if c.nil?
        col1=col[0]+' '+col[1]
        v.colour=Colour.find(:first, :conditions => [ "name = ?", col1.titleize])
      else
        v.colour=c
      end

      v.specific_colour=f[f.downcase.index("(")+1..f.downcase.index(")")-1] if f.include? "("
      v.metallic_colour=true if f.include?("met")
    end
  end
  def set_price(v,f)
    unless f==''
      a=f.gsub(/[^\d\,\.]/, '|').split('|').reject! { |c| c.empty? }


      v.price=BigDecimal.new(a[0].gsub(/[\,]/, ''))
      v.price_vat=true if a[2].to_i==20
    end
  end
  def set_bargain_price(v,f)
    unless f==''
      a=f.gsub(/[^\d\,\.]/, '|').split('|').reject! { |c| c.empty? }
      v.bargain_price=BigDecimal.new(a[0].gsub(/[\,]/, ''))
      v.bargain_price_vat=true if a[2].to_i==20
    end
  end
  task :types => :environment do
    type_names=["Car","Bus","Truck","Bike","Caravan","Boat","Machinery"]
    type_names.each do |t|
      type=Type.new
      type.name=t
      type.save!
    end
  end
  task :bodytypes => :environment do
    bodytype_names=["Hatchback","Sedan","SUV","Wagon","Ute","Convertible","Coupe","Van","Cab Chassis"]
    bodytype_names.each do |t|
      bodytype=Bodytype.new
      bodytype.name=t
      bodytype.type_id=1
      bodytype.save!
    end
  end
  task :bike_bodytypes => :environment do
    bodytype_names=["Classical","Scooter","Moped","Bike","Chopper","Touring","Motocross","Enduro","Trial","ATV","Buggy","Moped car","Snowmobile","Other"]
    bodytype_names.each do |t|
      bodytype=Bodytype.new
      bodytype.name=t
      bodytype.type_id=4
      bodytype.save!
    end
  end
  task :fueltypes => :environment do
    fueltype_names=["Petrol","Diesel","Petrol + Gas (LPG)","Petrol + Gas (CNG)","Gas (LPG)","Gas (CNG)","Hybrid","Electric","Ethanol"]
    fueltype_names.each do |t|
      fueltype=Fueltype.new
      fueltype.name=t
      fueltype.save!
    end
  end
  task :transmissions => :environment do
    transmission_names=["Automatic","Manual","Semi-Automatic"]
    transmission_names.each do |t|
      transmission=Transmission.new
      transmission.name=t
      transmission.save!
    end
  end
  task :drivetypes => :environment do
    drivetype_names=["Four Wheel Drive","Front Wheel Drive","Rear Wheel Drive"]
    drivetype_names.each do |t|
      drivetype=Drivetype.new
      drivetype.name=t
      drivetype.save!
    end
  end
  task :climate_controls => :environment do
    cc=["Climate Control","Air Conditioning"]
    cc.each do |t|
      cc=ClimateControl.new
      cc.name=t
      cc.save!
    end
  end
  task :vehicles_again => :environment do
    vehicles=Vehicle.all
    vehicles.each do |v|
      v.save!

    end
  end
  task :makes => :environment do
    make_names=["Acura","Adler","Alfa Romeo","Ariel","Artega","Aston Martin","Audi","Austin","Autobianchi","Bentley","BMW","Brabus","Bricklin","Brilliance","Bugatti","Buick","BYD","Cadillac","Carver","Caterham","Chevrolet","Chrysler","Citroen","Dacia","Daewoo","Daihatsu","Daimler","Datsun","Delahaye","DeSoto","DKV","Dodge","Donkervoort","Eagle","Estfield","Eterniti","Excalibur","Ferrari","Fiat","Fisker","Fleetwood","Ford","Franklin","FSO","GAZ","Geely","Gemballa","Geo","GMC","Great Wall","Honda","Hyundai","Infiniti","Isuzu","Jaguar","Jensen","Kaiser","Kia","Koenigsegg","KTM","Lada","Lamborghini","Lancia","Lexus","Ligier","Lincoln","Lotus","Mahindra","Maserati","Mazda","MCC","McLaren","Mercedes-Benz","Mercury","MG","Mia Electric","MINI","Mitsubishi","Moeslein","Morris","Moskvich","Nissan","Norster","Oldsmobile","Opel","Pagani","Peugeot","PGO","Plymouth","Pontiac","Porsche","Proton","Qoros","RAF","Rambler","Renault","Riich","Rolls-Royce","Rover","Saab","Saturn","Sbarro","Scion","SEAT","Shuanghuan","Skoda","Smart","SMZ","Spyker","SsangYong","Subaru","Suzuki","Talbot","Tata","Tesla","Tiffany","Toyota","Triumph","Vauxhall","VAZ","Venturi","Vogelzang","Volkswagen","Volvo","Wartburg","Willys","Yue Loong","Yugo","ZAZ","ZIL","Zorzi"]
    make_names.each do |t|
      make=Make.new
      make.name=t
      make.save!
    end
  end
  task :countries => :environment do
    names=["Austria","Belgium","Bulgaria","Cyprus","Czech Republic","Denmark","England","Estonia","Finland","France","Germany","Greece","Hungary","Ireland","Italy","Japan","Latvia","Lithuania","Luxembourg","Malta","Netherlands","Norway","Poland","Portugal","Romania","Russia","Slovakia","Slovenia","Spain","Sweden","Switzerland","United Kingdom","United States of America"]
    names.each do |t|
      c=Country.new
      c.name=t
      c.save!
    end
  end

  task :regions => :environment do
    names=["Abja-Paluoja","Antsla","Elva","Haapsalu","Jõgeva","Jõhvi","Kallaste","Kärdla","Karksi-Nuia","Kehra","Keila","Kilingi-Nõmme","Kiviõli","Kohtla-Järve","Kunda","Kuressaare","Lihula","Loksa","Maardu","Mõisaküla","Mustvee","Narva","Narva-Jõesuu","Otepää","Paide","Paldiski","Pärnu","Põltsamaa","Põlva","Püssi","Rakvere","Räpina","Rapla","Saue","Sillamäe","Sindi","Suure-Jaani","Tallinn","Tamsalu","Tapa","Tartu","Tõrva","Türi","Valga","Viljandi","Võhma","Võru","Harjumaa","Hiiumaa","Ida-Virumaa","Järvamaa","Jõgevamaa","Lääne-Virumaa","Läänemaa","Pärnumaa","Põlvamaa","Raplamaa","Saaremaa","Tartumaa","Valgamaa","Viljandimaa","Võrumaa"]
    names.each do |t|
      c=Region.new
      c.name=t
      c.country_id=8
      c.save!
    end
  end
  task :states => :environment do
    names=["Harjumaa","Hiiumaa","Ida-Virumaa","Järvamaa","Jõgevamaa","Lääne-Virumaa","Läänemaa","Pärnumaa","Põlvamaa","Raplamaa","Saaremaa","Tartumaa","Valgamaa","Viljandimaa","Võrumaa"]
    names.each do |t|
      c=State.new
      c.name=t
      c.country_id=8
      c.save!
    end
  end
  task :cities => :environment do
    names=[["Abja-Paluoja",14],["Antsla",15],["Elva",12],["Haapsalu",7],["Jõgeva",5],["Jõhvi",3],["Kallaste",12],["Kärdla",2],["Karksi-Nuia",14],["Kehra",1],["Keila",1],["Kilingi-Nõmme",8],["Kiviõli",3],["Kohtla-Järve",3],["Kunda",6],["Kuressaare",11],["Lihula",7],["Loksa",1],["Maardu",1],["Mõisaküla",14],["Mustvee",5],["Narva",3],["Narva-Jõesuu",3],["Otepää",13],["Paide",4],["Paldiski",1],["Pärnu",8],["Põltsamaa",5],["Põlva",9],["Püssi",3],["Rakvere",6],["Räpina",9],["Rapla",10],["Saue",1],["Sillamäe",3],["Sindi",8],["Suure-Jaani",14],["Tallinn",1],["Tamsalu",6],["Tapa",6],["Tartu",12],["Tõrva",13],["Türi",4],["Valga",13],["Viljandi",14],["Võhma",14],["Võru",15]]
    names.each do |t|
      c=City.new
      c.name=t[0]
      c.state_id=t[1]
      c.save!
    end
  end
  task :bike_makes => :environment do
    require 'nokogiri'
    require 'open-uri'
    f = File.open("lib/tasks/bikes.xml")
    doc = Nokogiri::XML(f)
    f.close
    doc.xpath("//option").each do |o|
      make=Make.new
      make.name=o.content
      make.type_id=4
      make.save!
    end
  end
  task :colours => :environment do
    require 'nokogiri'
    require 'open-uri'
    f = File.open("lib/tasks/colors.xml")
    doc = Nokogiri::XML(f)
    f.close
    doc.xpath("//option").each do |o|
      colour=Colour.new
      colour.name=o.content.capitalize
      colour.save!
    end
  end
  task :tires => :environment do
    tires=[]
    require 'nokogiri'
    require 'open-uri'
    f = File.open("lib/tasks/tires.xml")
    doc = Nokogiri::XML(f)
    f.close
    doc.xpath("//option").each do |o|

      tires << "#{o.content}"

    end
    print tires

  end
  task :wheels => :environment do
    wheels=[]
    require 'nokogiri'
    require 'open-uri'
    f = File.open("lib/tasks/wheels.xml")
    doc = Nokogiri::XML(f)
    f.close
    doc.xpath("//option").each do |o|
      wheels << "#{o.content}"
    end
    print wheels
  end
  task :colours1 => :environment do
    colours=[]
    Colour.all.each do |o|
      colours << {name: "#{o.name}",id: o.id}
    end
    print colours
  end
  task :models => :environment do
    require 'nokogiri'
    require 'open-uri'
    f = File.open("lib/tasks/models.xml")
    doc = Nokogiri::XML(f)
    f.close
    doc.xpath("//optgroup").each do |o|
      make=Make.find(:first, :conditions => [ "name = ?", o["label"]])
      o.elements.each do |e|
        model_full=e.content
        series=model_full.match(/\[(.+)\] (.+)/).to_a.flatten[1]
        if series!=nil
          s=Serie.find_by_name(series)
          if s==nil
            m1=Serie.new
            m1.name=series
            m1.make_id=make.id
            m1.save!
            id=m1.id
          else
            id=s.id
          end
        end
        model=model_full.match(/\[(.+)\] (.+)/).to_a.flatten[2]
        m2=Model.new
        m2.make_id=make.id
        if model!=nil
          m2.name=model

          m2.serie_id=id
        else
          m2.name=model_full
        end
        m2.save!
      end

    end
  end
end