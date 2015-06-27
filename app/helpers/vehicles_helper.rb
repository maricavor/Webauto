module VehiclesHelper

  def get_time_id
    (Time.now.to_f * 1000).to_i.to_s
  end
  def get_price_change
    price_changes=@vehicle.price_changes
    size=price_changes.size
    if size<2
      html = <<-HTML
      <h4>No price changes</h4>
      HTML
    else
      price_diff=price_changes.first.value-price_changes.last.value
      if price_diff<0
        html = <<-HTML
        <h4 class='text-error' style="margin-bottom:0;">Price Increase</h4>
        <small class='muted'>Increased by #{currency(price_diff)}</small>
        HTML
      else
        html = <<-HTML
        <h4 class='text-success' style="margin-bottom:0;">Price Drop</h4>
        <small class='muted'>Reduced by #{currency(price_diff)}</small>
        HTML
      end

      html+= <<-HTML
      <br>
      <table class="table table-condensed" style="margin:0;">
      HTML
      html+= <<-HTML
      <tr><td>
      <span class="muted" style="text-decoration: line-through;">#{currency(price_changes.first.value) }</span>
      </td><td class="right"><span class="muted">#{price_changes.first.created_at.strftime("%b %d")}</span></td></tr>
      HTML
      if size>3
        html+= <<-HTML
        <tr><td>...</td><td></td></tr>
        <tr><td>
        <span class="muted" style="text-decoration: line-through;">#{currency(price_changes[size-2].value) }</span>
        </td><td class="right"><span class="muted">#{price_changes[size-2].created_at.strftime("%b %d")}</span></td></tr>
        HTML
      elsif size==3
        html+= <<-HTML
        <tr><td>
        <span class="muted" style="text-decoration: line-through;">#{currency(price_changes[size-2].value) }</span>
        </td><td class="right"><span class="muted">#{price_changes[size-2].created_at.strftime("%b %d")}</span></td></tr>
        HTML
      end
      html+= <<-HTML
      <tr><td>
      #{currency(price_changes.last.value) }
      </td><td class="right">Today</td></tr>
      HTML


      html+= <<-HTML
      </table>
      HTML
    end
    html.html_safe
  end
  def spec_details(details)
    _updated=[]
    details.each do |d|
     _updated << d if d[0]
    end
    text=''
    text+= "(" if _updated.size>0
    text+= _updated.map { |u| u[1].to_s}.join(", ")
    text+= ")" if _updated.size>0
    text
  end

  def breadcrumb(num,advert,page,badge_cond,active_cond)
    text=I18n.t("adverts.breadcrumb." + page)
    current_cond=advert.send(page+"?")
    (current_cond || !active_cond) ? _class="active" : _class=""
    content_tag :li, class: _class do
      content=content_tag(:span, num, class: "badge #{'badge-success' if badge_cond}")
      if _class=="active"
        content << (current_cond ? content_tag(:strong,text) : text)
      else
        content << link_to(text,send(page + "_advert_path",advert))
      end
      content << content_tag(:span,"/",class: "divider") unless page=="checkout"
      content.html_safe
    end    
  end

  def secret_phone(phone,advert,phone_type)
    if phone.present?
      if phone_type=="secondary"
      "#{phone.sub!(/.{4}$/,'* * * *')} <small>#{link_to t('vehicles.show.show'),show_secondary_phone_advert_path(advert),remote: true}</small>".html_safe
      else
      "#{phone.sub!(/.{4}$/,'* * * *')} <small>#{link_to t('vehicles.show.show'),show_primary_phone_advert_path(advert),remote: true}</small>".html_safe
      end
    end
  end
  def secret_nr(vehicle)
    nr=vehicle.reg_nr
    if nr.present?
    "#{spec(nr.sub!(/.{4}$/,'* * * *'))} <small>#{link_to t('vehicles.show.show'),show_reg_nr_vehicle_path(vehicle),remote: true}</small>".html_safe
    else
    spec("")
    end
  end
   def secret_vin(vehicle)
    vin=vehicle.vin
    if vin.present?
    "#{spec(vin.sub!(/.{8}$/,'* * * *'))} <small>#{link_to t('vehicles.show.show'),show_vin_vehicle_path(vehicle),remote: true}</small>".html_safe
    else
    spec("")
    end
  end
  def spec(value)
    if value.present?
      html = <<-HTML
      <strong>#{value}</strong>
      HTML
    else
      html = <<-HTML
      <span class="muted">#{t("vehicles.show.no_details")}</span>
      HTML
    end
      html.html_safe
  end
  def spec_title(title)
    html = <<-HTML
    <span class="lead text-info">#{title}
    </span>
    <br>
    HTML
    html.html_safe
  end
  def status_label(active)
    if active
      html = <<-HTML
      <span class="label label-success">Active</span>
      HTML
    else
      html = <<-HTML
      <span class="label">Not active</span>
      HTML
    end
    html.html_safe
  end
  def add_car_button
  
link_to '<i class="icon-plus icon-white"></i> Add a Car'.html_safe, new_car_path,:class=> "btn btn-info text-right hidden-phone"
  
   
link_to '<i class="icon-plus icon-white"></i> Add a Car'.html_safe, new_car_path,:class=> "btn btn-info text-left visible-phone"



  end

  def save_vehicle_button
    if current_user
      if current_user.saved_items.exists?(:vehicle_id => @vehicle.id)
        link_to ("<i class='icon-star'></i> "+t("vehicles.show.unsave")).html_safe, unsave_car_path(@vehicle),:id=>"save_vehicle_button",:class=> "btn btn-block",:remote=>true
      else
        link_to ("<i class='icon-star-empty'></i> "+t("vehicles.show.save")).html_safe, save_car_path(@vehicle),:id=>"save_vehicle_button",:class=> "btn btn-block",:remote=>true
      end
    else
      link_to ("<i class='icon-star-empty'></i> "+t("vehicles.show.save")).html_safe, save_car_path(@vehicle),:id=>"save_vehicle_button",:class=> "btn btn-block"
    end
  end
 def save_vehicle_button_mini(vehicle)
    if current_user
      if current_user.saved_items.exists?(:vehicle_id => vehicle.id)
        link_to '<i class="icon-star"></i>'.html_safe, unsave_car_path(vehicle),:id=>"save_vehicle_button",:class=>"btn btn-mini",:remote=>true
      else
        link_to '<i class="icon-star-empty"></i>'.html_safe, save_car_path(vehicle),:id=>"save_vehicle_button",:class=>"btn btn-mini",:remote=>true
      end
    else
      link_to '<i class="icon-star-empty"></i>'.html_safe, save_car_path(vehicle),:class=>"btn btn-mini",:id=>"save_vehicle_button"
    end
  end
  def link_to_more_options
   content_tag(:small) do
      link_to(t("search.more_options"), '#',class: "more_options")
    end
  end
   def link_to_less_options
   content_tag(:small) do
      link_to(t("search.less_options"), '#',class: "less_options")
    end
  end
    def link_to_expand_search
    content_tag(:h5,class: "expand_search") do
      link_to("#{t('search.open_search')} <i class='icon-chevron-down'></i>".html_safe, '#')
    end
    
  end
   def link_to_collapse_search
   content_tag(:h5,class: "collapse_search") do
      link_to("#{t('search.close_search')} <i class='icon-chevron-up'></i>".html_safe, '#')
    end
 
  end
  def link_to_add_fields(name, f, association)
    new_object = f.object.send(association).klass.new
    id = new_object.object_id
    fields = f.fields_for(association, new_object, child_index: id) do |builder|
      render("vehicles/partials/"+association.to_s.singularize + "_fields", f: builder,:remove_link=>true )
    end
    content_tag(:small) do
      link_to(name, '#', class: "add_fields",data: {id: id, fields: fields.gsub("\n", "")})
    end
  end
  def get_prices
    i = 2500
    prices=[]
    while i <= 100000  do
        prices.push ["#{currency(i)}",i]
        if i<10000
          i+=2500
        elsif i>=10000 && i<50000
          i+=5000
        else
          i+=10000
        end
      end
      prices
    end
    def get_powers
      powers=[]
      [80, 100, 125, 150, 175, 200, 225, 250, 300, 350].each do |i|
        powers.push ["#{i} kW",i]
      end
      powers
    end
    def get_kms
      kms=[]
      [10000, 20000 ,40000,60000,80000,100000,150000,200000].each do |i|
        kms.push [milage(i),i]
      end
      kms
    end
    def milage(km)
      "#{number_with_delimiter(km, delimiter: ",")} km"
    end
    def get_years
      ret=[]
      years=(1900..Time.now.year).to_a
      years.each do |i|
        ret.push [i,i]

      end
      ret
    end
    def get_min_years
      ret=[]
      years=[1920,1930,1940,1950,1960,1970,1980]+(1990..Time.now.year).to_a
      years.each do |i|
        ret.push [i,Date.new(i)]

      end
      ret
    end
    def get_max_years
      ret=[]
      years=[1920,1930,1940,1950,1960,1970,1980]+(1990..Time.now.year).to_a
      years.reverse.each do |i|
        ret.push [i,Date.new(i+1)]

      end
      ret
    end
    def get_seats
      seats=[]
      [1,2, 3, 4, 5, 6, 7, 8, 9].each do |i|
        seats.push [i,i]
      end
      seats
    end

    def get_doors
      doors=[]
      [2, 3, 4, 5, 6].each do |i|
        doors.push ["#{i}",i]
      end
      doors
    end
    def get_wheel_sizes
      wheels=[]
      ["R12","R13","R14","R15","R16","R17","R18","R19","R20","R21","R22","R23"].each do |i|
        wheels.push ["#{i}",i]
      end
      wheels
    end
    def get_tire_sizes
      tires=[]
      ["31/10.50R15", "60/100-14", "70/100-17", "120/80-19", "155/65R14", "155/70R13", "155/80R12C", "165/65R14", "165/70R14", "165/70R14C", "165/80R13C", "175/65R14", "175/65R15", "175/65R14C", "175/70R13", "175/70R14", "175/70R14C", "175/75R16C", "185/55R15", "185/60R15", "185/60R14", "185/65R14", "185/65R15", "185/70R14", "185/75R16C", "185/80R14C", "195/50R15", "195/50R16", "195/55R16", "195/55R15", "195/60R15", "195/60R16C", "195/60R14", "195/60R16", "195/65R16C", "195/65R15", "195/65R14", "195/70R15C", "195/70R15", "195/75R16C", "195/80R14C", "195/80R15", "205/45R16", "205/45R17", "205/50R17", "205/50R16", "205/55R16", "205/55R15", "205/55R17", "205/60R15", "205/60R16", "205/65R16C", "205/65R15C", "205/65R15", "205/70R15", "205/70R15C", "205/75R16C", "205/80R16", "215/40R17", "215/45R17", "215/50R17", "215/55R17", "215/55R16", "215/60R17", "215/60R16", "215/60R16C", "215/65R16", "215/65R16C", "215/65R15", "215/65R15C", "215/70R16", "215/70R15C", "215/75R16C", "225/35R18", "225/40R18", "225/45R17", "225/45R18", "225/50R17", "225/50R16", "225/55R17", "225/55R16", "225/55R18", "225/60R16", "225/60R17", "225/60R18", "225/65R17", "225/65R18", "225/65R16C", "225/70R16", "225/70R15C", "225/75R16C", "235/35R19", "235/40R18", "235/45R17", "235/45R18", "235/50R18", "235/55R18", "235/55R17", "235/55R19", "235/60R16", "235/60R18","235/65R16C", "235/65R17", "235/65R18", "235/70R16", "235/75R15", "245/35R19", "245/35R21", "245/35R18", "245/35R20", "245/40R18", "245/40R20", "245/40R17", "245/40R19", "245/45R19", "245/45R17", "245/45R18", "245/50R18", "245/65R17", "245/70R16", "255/35R20", "255/35R18", "255/35R19", "255/40R19", "255/40R17", "255/40R18", "255/45R18", "255/45R20", "255/50R19", "255/50R20", "255/55R18", "255/55R19", "255/60R18", "255/60R17", "255/65R16", "255/70R15", "255/70R16", "265/35R18", "265/35R19", "265/50R19", "265/50R20", "265/60R18", "265/65R17", "265/70R16","265/75R16", "275/30R20", "275/30R19", "275/40R20", "275/40R19", "275/45R20", "275/55R19", "275/55R17", "275/60R18", "275/70R16", "285/30R21", "285/45R19", "285/50R20", "285/60R18", "295/35R21", "295/40R20", "315/35R20", "315/35R21", "325/30R21"].each do |i|
        tires.push ["#{i}",i]
      end
      tires
    end
     def get_features
      features=t("features").map {|f| ["#{f['name']}","#{f['id']}"]}
    end
    def toggle_watching_button
      text= if @vehicle.watchers.include?(current_user)
        "Stop watching this vehicle"
      else
        "Watch this vehicle"
      end
      link_to text, watch_car_path(@vehicle),:class=> "btn btn-small",:remote=>true
    end
    def parking_sensors
      sensors=[]
      sensors << t("vehicles.show.front") if @vehicle.parking_aid_front
      sensors << t("vehicles.show.rear") if @vehicle.parking_aid_rear
      sensors.size>0 ? "("+sensors.join(', ')+")" : ""
    end
    def mirrors
      m=[]
      m << t("vehicles.show.heated_mirrors") if @vehicle.heated_mirrors
      m << t("vehicles.show.folding_mirrors")  if @vehicle.folding_mirrors
      m << t("vehicles.show.with_memory")  if @vehicle.mirrors_with_memory
      m.size>0 ? "("+m.join(', ')+")" : ""
    end
    def xenon
      x=[]
      x << t("vehicles.show.low_beam") if @vehicle.xenon_low_beam
      x << t("vehicles.show.high_beam") if @vehicle.xenon_high_beam
      x.size>0 ? "("+x.join(', ')+")" : ""
    end
    def fog_lights
      f=[]
      f << t("vehicles.show.front") if @vehicle.fog_lights_front
      f << t("vehicles.show.rear") if @vehicle.fog_lights_rear
      f.size>0 ? "("+f.join(', ')+")" : ""
    end
  end