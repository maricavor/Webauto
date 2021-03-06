require "uri"
require "net/http"
require 'nokogiri'
require 'digest/sha2'

class VehiclesController < ApplicationController
  skip_before_filter :get_current_type,:get_compared_items, :only=>[:show_reg_nr,:show_vin,:show_similar,:show_more_dealer,:show_viewed,:show_interesting,:show_states,:show_cities,:sort_photos]
  before_filter :set_current_type,:only=>[:index,:search]
  before_filter :authenticate_user!, :only=>[:save,:watch,:unsave,:destroy]
  before_filter :set_params,:only=>[:index,:search]
  before_filter :find_vehicle, :only => [:show,:save,:compare,:uncompare,:destroy,:watch,:sort_photos,:show_similar,:show_interesting,:show_more_dealer,:unsave,:show_viewed,:show_reg_nr,:show_vin]
  before_filter :check_status, :only=>[:show]
 
  def set_params
    @row_size=4
    @per_page=20
  end
  
  def index
    @title=t("vehicles.index.title")
    @search= Search.new
    #@search.location=8
    @remote=false
    @search.fields.build
    @class=''
    @popular_makes=Make.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
    @popular_models=Model.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
    @popular_bodytypes=Bodytype.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
    @last_reviews=Review.where(:accepted=>true).order("created_at desc").limit(2)
    gon.selected=@search.to_gon_object
  end

 def search
    @remote=false
    if params[:id]
     set_current_sort
     @search = Search.find(params[:id])
     @title=t("vehicles.index.title")
     @search.dealers ? dealers=@search.dealers.split(",") : dealers=[]
     if dealers.size==1
      dealer=User.find(dealers[0])
      redirect_to send("search_dealer_path", dealer.dealer_name,:search_id=>@search,:sort=>"most_recent")
     end
     @search.fields.build if @search.fields.size==0
     #params[:page] ? per=@per_page : per=100 #use this to search 100 and save it to saved search  check paginated collection how to limit 
     @solr_search=@search.run("normal",@current_sort[1].split(' '),params[:page] ,@per_page)
     @total=@solr_search.total 
     
      if @total>0
        
        @vehicles = @solr_search.results
      
     
      else
        @vehicles=[]
      
        #@title=t("vehicles.nothing")
      end
     
      gon.selected=@search.to_gon_object
    else
      redirect_to new_search_path(:search=>"all")
    end
    end

  def search_old
    @remote=false
    @class="search "
    #@recently_viewed=get_recently_viewed_vehicles
    #@last_search=get_last_search
    if params[:id]
      set_current_sort
      @search = Search.find(params[:id])
      @search.fields.build if @search.fields.size==0
      keywords=@search.keywords
      type= @search.tp
      bodytype=@search.bt
      fueltype=@search.ft
      transmission=@search.tm
      drivetype=@search.dt
      colour=@search.cl
      fpgt=@search.fpgt
      fplt=@search.fplt
      pwgt=@search.pwgt
      pwlt=@search.pwlt
      kmgt=@search.kmgt
      kmlt=@search.kmlt
      exception=@search.exception
      country=@search.location
      region=@search.region
      yeargt=@search.yeargt
      yearlt=@search.yearlt
      stgt=@search.stgt
      stlt=@search.stlt
      doors=@search.doors
      is_dealer=@search.is_dealer
      is_private=@search.is_private
      fields=@search.fields
      features=@search.features
      sort=@current_sort[1].split(' ')
      per_page=@per_page
      @solr_search = Vehicle.search do
        fulltext keywords if keywords.present?
        any_of do
          fields.each do |f|
            all_of do
              f.attributes.each_pair do |name,value|
                if name=="make_name"
                  with(:make_name,value) if value.present?
                end
                if name=="model_name"
                  if value.present?
                    any_of do
                      with(:model_name,value.split(','))
                      with(:serie_name).any_of(value.split(','))
                    end
                  end
                end
              end
            end
          end
        end
        unless features.nil?
        features.split(',').each do |feat|
          if feat=="climate_control_id"
          with(feat,"1")
          else
          with(feat,true)
          end
        end
        end
        with(:type_id, type) if type.present?
        with(:bodytype_id,bodytype.split(",")) if bodytype.present?
        with(:price).greater_than_or_equal_to(fpgt) if fpgt.present?
        with(:price).less_than_or_equal_to(fplt) if fplt.present?
        with(:engine_power).greater_than_or_equal_to(pwgt) if pwgt.present?
        with(:engine_power).less_than_or_equal_to(pwlt) if pwlt.present?
        with(:odometer).greater_than_or_equal_to(kmgt) if kmgt.present?
        with(:odometer).less_than_or_equal_to(kmlt) if kmlt.present?
        with(:registered_at).greater_than_or_equal_to(yeargt) if yeargt.present?
        with(:registered_at).less_than_or_equal_to(yearlt) if yearlt.present?
        with(:seats).greater_than_or_equal_to(stgt) if stgt.present?
        with(:seats).less_than_or_equal_to(stlt) if stlt.present?
        with(:doors,doors.split(",")) if doors.present?
        with(:fueltype_id,fueltype.split(",")) if fueltype.present?
        with(:transmission_id,transmission.split(",")) if transmission.present?
        with(:drivetype_id,drivetype.split(",")) if drivetype.present?
        with(:colour_id,colour.split(",")) if colour.present?
        with(:country_id,country.split(",")) if country.present?
        without(:advert_id,nil)
        without(:id,exception) unless exception.nil?
        with(:activated,true)
        if region.present?
          any_of do
            with(:state,region.split(","))
            with(:city,region.split(","))
          end
        end
        any_of do
          with(:is_dealer,true) if is_dealer
          with(:is_dealer,false) if is_private
        end
        order_by(sort[0], sort[1])
        order_by(:ad_activated_at, :desc) if sort[0]=="popularity"
        paginate(:page => params[:page], :per_page => per_page)
      end
      if @solr_search.total>0
        @vehicles = @solr_search.results
      else
        @vehicles=nil
        @title="Nothing found"
      end
      gon.selected=@search.to_gon_object

    else
   
      redirect_to new_search_path(:search=>"all")
    
   
      
    end
  end
  ######
  def show_phone
   vehicle=Vehicle.find(params[:id])
   @primary_phone=vehicle.advert.contact_number
   @secondary_phone=vehicle.advert.secondary_number
   render 'users/show_phone', :formats => [:js]
 end
  
  def show
    @user=@vehicle.user
    @title="#{@vehicle.name} #{@vehicle.transmission}"
    @pictures=@vehicle.pictures
    @comment=@vehicle.comments.build
    @advert=@vehicle.advert
    #@recently_viewed=get_recently_viewed_vehicles - [@vehicle]
    @inquiry=Inquiry.new
    @remote=false
    @search= Search.new
    @make=@vehicle.make
    @make_name=@vehicle.make_name
    @model_name=@vehicle.model_name

    #@similar_vehicles=Vehicle.where("id <> ? AND make_id = ? AND model_id = ? AND advert_id IS NOT ?",@vehicle.id,@make.id,@vehicle.model.id,nil).order("popularity desc","created_at desc").limit(6)
    update_impressions

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @vehicle }
    end
  
  end


    def show_reg_nr
    @reg_nr=@vehicle.reg_nr
       respond_to do |format|
          format.js {
            render :action => 'show_reg_nr.js.erb'
          }
        end
  end
     def show_vin
    @vin=@vehicle.vin
       respond_to do |format|
          format.js {
            render :action => 'show_vin.js.erb'
          }
        end
  end
def show_viewed

    id=@vehicle.id
    rvv=[]
    ids=[]
    sessions={}
   if current_user
     _impressions=@vehicle.impressions.where("user_id <> ? AND ip_address <> ?",current_user.id,request.remote_ip).order("created_at desc")
    else
    _impressions=@vehicle.impressions.where("ip_address <> ?",request.remote_ip).order("created_at desc")
    end
    
    #
    #_impressions.each do |im|
      #logger.info "Analyzing impression "+im.id.to_s
      #vehicle=im.vehicle
     # ad=vehicle.advert
     # if ad.activated?  
     # v_id=im.vehicle_id
      #vs=im.session_hash
     # if v_id==id
      #   ids << v_id
      #   sessions[vs]=nil
         #logger.info "Saved session "+vs.to_s
         #end
     # if sessions.has_key? vs
      #logger.info "Session exists"
     # unless ids.include? v_id 
        #logger.info "Saved vehicle "+v_id.to_s
      #  ids << v_id 
      #  rvv << vehicle
     # end
      #end
     # end
    #end
    # if rvv.size>0
      #SORT HERE ON POPULARITY
       # @vehicles = rvv
      #else
      #  @vehicles=nil
      #end

end

  def show_similar
 
    id=@vehicle.id
     model_name=@vehicle.model_name
     make_name= @vehicle.make_name
     type_id=@vehicle.type_id
     transmission_id=@vehicle.transmission_id
      @solr_search = Vehicle.search do
        with(:model_name,model_name) 
        with(:make_name,make_name)   
        with(:type_id, type_id) 
        with(:transmission_id,transmission_id) 
        #with(:registered_at).greater_than_or_equal_to(vehicle.registered_at)
        #with(:registered_at).less_than_or_equal_to(vehicle.registered_at) 
        without(:advert_id,nil)
        without(:id,id)
        with(:activated,true)
        #order_by(:popularity,:desc)
        order_by(:ad_activated_at, :desc)
        paginate(:page => 1, :per_page => 6)
      end
      if @solr_search.total>0
        @vehicles = @solr_search.results
      else
        @vehicles=nil
      end
   
  end
  def show_more_dealer
     id=@vehicle.id
     @user=@vehicle.user
     user_id=@vehicle.user_id
     type_id=@vehicle.type_id
      @solr_search = Vehicle.search do  
        with(:type_id, type_id)  
        without(:advert_id,nil)
        without(:id,id)
        with(:user_id,user_id)
        with(:activated,true)
        order_by(:ad_activated_at, :desc)
        paginate(:page => 1, :per_page => 6)
      end
      if @solr_search.total>0
        @vehicles = @solr_search.results
      else
        @vehicles=nil
      end
   
  end
  def show_interesting
  
  id=@vehicle.id
     model_name=@vehicle.model_name
    make_name= @vehicle.make_name
     type_id=@vehicle.type_id
    bodytype_id=@vehicle.bodytype_id
     #transmission_id=@vehicle.transmission_id
     price=@vehicle.price
     odometer=@vehicle.odometer
      @solr_search = Vehicle.search do  
        without(:model_name,model_name) 
        without(:make_name,make_name)
        with(:type_id, type_id) 
        with(:bodytype_id,bodytype_id)
        without(:advert_id,nil)
        without(:id,id)
        with(:activated,true)
        with(:price).greater_than_or_equal_to(price-1500) 
        with(:price).less_than_or_equal_to(price+1500) 
        with(:odometer).greater_than_or_equal_to(odometer-20000) if odometer.present?
        with(:odometer).less_than_or_equal_to(odometer+20000) if odometer.present?
        #order_by(:popularity,:desc)
        order_by(:ad_activated_at, :desc)
        paginate(:page => 1, :per_page => 6)
      end
      if @solr_search.total>0
        @vehicles = @solr_search.results
      else
        @vehicles=nil
      end
 
  end

  def unsave
    @saved_item=current_user.saved_items.find_by_vehicle_id(@vehicle.id)
    @saved_item.destroy
      respond_to do |format|
        format.html {redirect_to dashboard_url, notice: t("vehicles.unsaved")}
        format.js { flash.now[:notice] = t("vehicles.unsaved")}
      end
  end
  def uncompare
 @compared_item=@vehicle.compared_items.find_by_session_hash(request.session_options[:id]
    )
    @compared_item.destroy
      respond_to do |format|
        format.html { redirect_to dashboard_url, notice: t("vehicles.uncompared") }
        format.js { flash.now[:notice]=t("vehicles.uncompared") }
      end
  end

  
  def compare
    @compared_item=ComparedItem.new
    @compared_item.vehicle_id=@vehicle.id
    if current_user
    @compared_item.user_id=current_user.id 
    end
    @compared_item.ip_address=request.remote_ip
    @compared_item.session_hash = request.session_options[:id] 
    if @compared_item.save
      respond_to do |format|
        format.html {
          redirect_to send("#{@vehicle.type.name.singularize.underscore}_path", @vehicle), notice: t("vehicles.compared")}
        format.js { flash.now[:notice] = t("vehicles.compared")}
      end
    else
      respond_to do |format|
        format.html {  redirect_to send("#{@vehicle.type.name.singularize.underscore}_path", @vehicle) ,alert: @compared_item.errors.full_messages.to_sentence}
        format.js {
          flash.now[:alert] =  @compared_item.errors.full_messages.to_sentence
          render 'fail_save'

        }
      end

    end
  end

  def save
    @saved_item=current_user.saved_items.build
    @saved_item.vehicle_id=@vehicle.id
    
    @saved_item.type_id=@vehicle.type_id
    if @saved_item.save
      respond_to do |format|
        format.html {redirect_to dashboard_url, notice: t("vehicles.saved")}
        format.js { flash.now[:notice] = t("vehicles.saved")}
      end
    else
      respond_to do |format|
        format.html {  
          redirect_to send("#{@vehicle.type.name.singularize.underscore}_path", @vehicle) ,alert: @saved_item.errors.full_messages.first}
        format.js {
          flash.now[:alert] =  @saved_item.errors.full_messages.first
          render 'fail_save'
        }
      end

    end
  end

   def sort_photos
    @pictures = @vehicle.pictures
    @pictures.each do |pic|
      pic.position = params["pic"].index(pic.id.to_s)+1
      pic.save!
    end
    flash[:notice] =  t("vehicles.photos_resorted")# + params["pic"].to_s
    flash.discard
    #render :nothing => true
  end
  def show_states
    if params["country_id"]!=""
      country=Country.find(params["country_id"])
      _states=country.states
      _cities=country.cities
      _states.size>0 ? @states=_states.map{|a| [a.name,a.id]}.insert(0,[t("adverts.details.select_state"),""]) : @states=[]
      _cities.size>0 ? @cities=_cities.map{|a| [a.name,a.id]}.insert(0,[t("adverts.details.select_city"),""]) : @cities=[]
    else
      @states=[]
      @cities=[]
    end
  end
  def show_cities
    if params["state_id"]!=""
      state=State.find(params["state_id"])
      _cities=state.cities
      _cities.size>0 ? @cities=_cities.map{|a| [a.name,a.id]}.insert(0,[t("adverts.details.select_city"),""]) : @cities=[]
    else
      @cities=[]
    end
  end
  def show_regions_in_search
    if params["country_id"]!=""
      country=Country.find(params["country_id"])
      _states=country.states
      _cities=country.cities
      _states.size>0 ? @regions=_states.map{|p| [ p.name.upcase, p.name ] }+_cities.map{|p| [ p.name, p.name ] } : @regions=[]
    else
      @regions=[]
    end
  end
  def update_states
    if params["city_id"]!=""
      city=City.find(params["city_id"])
      @state_id=city.state.id
    else
      render :nothing =>true
    end
  end
  def find_details
    @vehicle = Vehicle.new
    @vehicle.reg_nr=params["regmark"]

    get_basic_details({'regmark' => params["regmark"],'button' => 'P%C3%84RING'})

    if @vehicle.valid?
      @vehicle.update_attr
      render json: {object: @vehicle, id: @vehicle.to_param}
      # render json: {object: @vehicle, id: @vehicle.to_param,doc:@doc.to_s.html_safe }
    else
      render text:  @vehicle.errors.full_messages.first
    end
  end
 
  # DELETE /vehicles/1
  # DELETE /vehicles/1.json
  def destroy
    unless @vehicle.user==current_user
    @vehicle.destroy

    respond_to do |format|
      format.html { redirect_to  adverts_url }
      format.json { head :no_content }
    end
end
  end

  def watch
    if @vehicle.watchers.exists?(current_user)
      @vehicle.watchers -= [current_user]
      respond_to do |format|
        format.html {redirect_to @vehicle, notice: t("vehicles.not_watching")}
        format.js { flash.now[:notice] = t("vehicles.not_watching")}
      end

    else
      @vehicle.watchers << current_user
      respond_to do |format|
        format.html {  redirect_to :back,notice: t("vehicles.watching")}
        format.js {
          flash.now[:notice]=t("vehicles.watching")
        }
      end

    end

  end

  def get_index_vehicles(t_id)
    @recent_adverts = Advert.where(:type_id =>t_id,:activated=>true).order("activated_at desc").limit(12)
    @viewed_vehicles=get_viewed_vehicles(t_id)
    @popular_vehicles=get_popular_vehicles(t_id)
  end
  
  def get_popular_vehicles(t_id)
     solr_search = Vehicle.search do  
       with(:type_id, t_id)  
       without(:advert_id,nil)
       with(:activated,true)
       #order_by(:ad_activated_at, :desc)
       order_by(:popularity, :desc)
       paginate(:page => 1, :per_page => 12)
     end
     if solr_search.total>0
       vehicles = solr_search.results
     else
       vehicles=nil
     end
     vehicles
end

  

  def get_recently_viewed_vehicles

    rvv=[]
    ids=[]
   if current_user

    _impressions=current_user.impressions.order("created_at desc")
    else
    _impressions=Impression.where(:ip_address=>request.remote_ip,:user_id=>nil).order("created_at desc")
    end
    _impressions.each do |im|
       v_id=im.vehicle_id
       unless ids.include? v_id
         vehicle=im.vehicle
         if vehicle.advert.activated && vehicle.type_id==@current_type.id
         ids << v_id
         rvv << vehicle
       end
       end
    end
    if rvv.size>0
    @vehicles=rvv
  else
    @vehicles=nil
  end
  end
  private

  def update_impressions
    impressionist_hash = Digest::SHA2.hexdigest(Time.now.to_f.to_s+rand(10000).to_s)
    if session_hash!=nil
    #unless @vehicle.impressions.where("session_hash = ? OR ip_address = ?",session_hash,@vehicle.user.last_sign_in_ip).exists?
    unless @vehicle.impressions.where(:session_hash=>session_hash).exists?
    if current_user
      unless @user==current_user
      @impression = @vehicle.impressions.create(:controller_name => controller_name,:action_name => action_name,:user_id => user_id,:request_hash => impressionist_hash,:session_hash => session_hash,:ip_address => request.remote_ip,:referrer => request.referer) 
      pop=@vehicle.popularity+1
      #@vehicle.save(:validate => false)
      @vehicle.update_column(:popularity,pop)
      end
    else
      @impression = @vehicle.impressions.create(:controller_name => controller_name,:action_name => action_name,:user_id => nil,:request_hash => impressionist_hash,:session_hash => session_hash,:ip_address => request.remote_ip,:referrer => request.referer)
      pop=@vehicle.popularity+1
      @vehicle.update_column(:popularity,pop)
    end
    end
    end  
  end

  def get_viewed_vehicles(t_id)
    vehicles=[]
    impressions=Impression.order("created_at desc").first(100)
    impressions.each do |i|
      vehicle=i.vehicle
      unless vehicles.include?(vehicle)
      vehicles << vehicle if vehicle.type_id==t_id && vehicle.advert.activated
    end
     end
    vehicles.first(12)
  end

  def find_vehicle
    @vehicle=Vehicle.with_deleted.find(params[:id])
  end



 





  def get_full_details(prms)
    request = Net::HTTP.post_form(URI.parse('http://195.80.106.137:9050/saap'), prms)
    response=request.body.force_encoding("UTF-8")
    @doc=Nokogiri::HTML(response)
    puts @doc
  end

  def get_basic_details(prms)
    request = Net::HTTP.post_form(URI.parse('http://195.80.106.137:9050/soidukiPiirang'), prms)
    response=request.body.force_encoding("UTF-8")
    @doc=Nokogiri::HTML(response)
    make=""
    model=""
    reg=""
    @doc.css("table.vehicle tr").each do |tr|
      v=tr.text.downcase
      if v.include? "mark"
        make=v.sub("mark:",'').strip
        @vehicle.make= @makes.find(:first, :conditions => ["lower(name) = ?", make])

      end
      if v.include? "mudel"
        model=v.sub("mudel:",'').strip
        if @vehicle.make
          @vehicle.make.models.each do |m|
            if model.index(m.name.downcase)==0
              @vehicle.model=m
              badge=model.sub(m.name.downcase,'').strip
              @vehicle.badge=badge.upcase if badge!=""
              break
            end
          end
        end
      end
      if v.include? "registreerimine"
        reg=v.sub("esmane registreerimine: ",'').strip
        dat=Date.strptime(reg, "%d.%m.%Y")
        @vehicle.registered_at=dat if dat
      end
    end

  end
  def save_vehicle
  if @vehicle.save
  end
  end
  def get_last_search
    if current_user
    last_search=Search.where(:user_id=>current_user.id).order("created_at desc").last
  else
    last_search=Search.where(:user_ip=>request.remote_ip,:user_id=>nil).order("created_at desc").last
  end
  last_search
  end
 
  #use both @current_user and current_user helper
    def user_id
      user_id = @current_user ? @current_user.id : nil rescue nil
      user_id = current_user ? current_user.id : nil rescue nil if user_id.blank?
      user_id
    end
    def session_hash
      # # careful: request.session_options[:id] encoding in rspec test was ASCII-8BIT
      # # that broke the database query for uniqueness. not sure if this is a testing only issue.
      # str = request.session_options[:id]
      # logger.debug "Encoding: #{str.encoding.inspect}"
      # # request.session_options[:id].encode("ISO-8859-1")
      request.session_options[:id]
    end

   def check_status
    advert=@vehicle.advert
    if advert
    if advert.destroyed?
      flash[:alert]=t("vehicles.ad_destroyed_status")
      redirect_to root_url
    else
      unless advert.activated
        flash[:alert]=t("vehicles.ad_deactivated_status")
        redirect_to root_url
      end
    end
  else
  flash[:alert]=t("vehicles.ad_status")
  redirect_to root_url
  end
    
    
    
  
   end
end