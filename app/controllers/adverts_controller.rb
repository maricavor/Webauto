class AdvertsController < ApplicationController
  helper_method :sort_column, :sort_direction
  skip_before_filter :get_current_type,:get_compared_items, :only=>[:statistics,:restore,:show_secondary_phone,:show_primary_phone,:activate,:deactivate,:destroy,:update]
  before_filter :authenticate_user!, :except=>[:show_secondary_phone,:show_primary_phone]
  before_filter :find_advert, :only => [:really_destroy,:edit,:statistics,:update,:restore,:details,:destroy,:features,:photos,:contact,:show,:preview,:checkout,:activate,:deactivate]
  before_filter :only=>[:edit] do |controller|
    controller.init_gon(1)
  end
  def index
      @user=current_user
      sort=sort_column + ' ' + sort_direction
      page=params[:page]
      per=10
      @adverts=@user.adverts.with_deleted.order(sort).page(page).per(per)
  end
  def new
    @advert=Advert.new
    #@advert.build_vehicle(user_id: current_user.id,type_id: @current_type.id)
    #############
  end
  def create
    @advert = Advert.new(params[:advert])
      respond_to do |format|
     if @advert.save
       if @advert.ad_type=="Free"
        service=Service.find(2)
      else
        service=Service.find(1)
      end
        @advert.create_vehicle!(user_id: current_user.id,type_id: @current_type.id)
        @order=@advert.create_order!
        @order.line_items.create!(service_id: service.id)
        format.html { redirect_to edit_advert_path(@advert) }
      else
        format.html { render action: "new" }
      end
    end
  end

  def statistics
  @vehicle=@advert.vehicle
  impressions=@vehicle.impressions.where('created_at > ?', 30.days.ago).order("created_at ASC")
  @imp_hash={}
  (Date.today - 30.days).upto(Date.today) do |date| 
    @imp_hash[date.strftime("%d/%m")]=0 
   end
  impressions.each do |imp|
  @imp_hash[imp.created_at.strftime("%d/%m")]+=1
  end
  data_table = GoogleVisualr::DataTable.new
# Add Column Headers
  data_table.new_column('string', 'Day' )
  data_table.new_column('number', 'Views')
  max_value=@imp_hash.max_by{|k,v| v}[1]
  # Add Rows and Values
  data_table.add_rows(@imp_hash.collect { |k, v| [k,v] })
  option = { width: 960,height:450, :title => t("adverts.statistics.views_title"),chartArea:{left:90,top:50,width:860,height:300},:legend=>{:position=>'none'},:vAxis => {:title => t("adverts.statistics.views"),:maxValue=>max_value,:minValue=>0}, :hAxis => {:slantedText=>true,:slantedTextAngle=>90}  }
  @chart = GoogleVisualr::Interactive::ColumnChart.new(data_table, option)
  end
 def show
   vehicle=@advert.vehicle
   type=vehicle.type.name
   redirect_to send("#{type.singularize.underscore}_path", vehicle)
 end
  def restore
    id=@advert.id
    vehicle=@advert.vehicle
    Advert.restore(id)
    Vehicle.restore(vehicle.id,:recursive => true)
    @advert=Advert.find(id)
     respond_to do |format|
    if vehicle.save
      @advert.save!#for changing status
      format.html { redirect_to  adverts_url }
      format.js { flash.now[:notice]="Successfully restored advert"}
    else
      format.html { redirect_to  adverts_url }
      format.js {
        render :action => 'restore_fail.js.erb'
        flash.now[:notice]="Could not restore advert"
      }
    end
    end
 
  end

 def edit
    @action="edit"
    @advert.current_step=session[:advert_step]=@action
    @vehicle=@advert.vehicle
    @bodytypes=Bodytype.where(:type_id=>@vehicle.type_id).order(:name)
    gon.selected={"vehicles"=>[@vehicle.make.name,@vehicle.model_name,@vehicle.model_id]} if @vehicle.make
  end

  def update
    @advert.current_step = session[:advert_step]
    respond_to do |format|
    if @advert.update_attributes(modify(params[:advert]))
      if @advert.last_step? || params[:save_show]
        session[:advert_step] =  nil
        @redirect_path=car_path(@advert.vehicle)
        message=params[:save_activate] ? "Your advert is saved and activated!" : "Your advert is saved!"
        format.html {
        #redirect_to action: 'preview'
        redirect_to @redirect_path
        flash[:notice]=message
      }
     format.js {
        
        flash.now[:notice]=message
      }
   
      elsif params[:save_preview]
         session[:advert_step] =  nil
         @redirect_path=preview_advert_path(@advert)
         format.html {
         redirect_to @redirect_path
         flash[:notice]="Your advert is saved!"
       }
       format.js {
         flash.now[:notice]="Your advert is saved!"
      }
   
      else
        @redirect_path=url_for action: @advert.next_step
        format.html {
        redirect_to @redirect_path
        flash[:notice]="Your advert is saved!"
      }
       format.js {
         flash.now[:notice]="Your advert is saved!"
       
      }
      end
    else
       @redirect_path=url_for action: @advert.current_step
       format.html {
      flash[:error]=@advert.errors.full_messages.first
      redirect_to @redirect_path
  
    }
    format.js { 
      flash.now[:error]=@advert.errors.full_messages.first
      
      
      }
    end
  end
  end
  def activate
    @vehicle=@advert.vehicle
    respond_to do |format|
    if @advert.update_attributes(:activated=>true)
       @vehicle.save!
      format.html {
       redirect_to  adverts_url 
       flash[:notice]="Successfully activated advert"
   }
      format.js { 
        
        flash.now[:notice]="Successfully activated advert"
    
      }
    end
    end
  end
  def deactivate
     @vehicle=@advert.vehicle
       respond_to do |format|
    if @advert.update_attributes(:activated=>false)
      @vehicle.save!
      format.html { 
        redirect_to  adverts_url 
      flash[:notice]="Successfully deactivated advert"
    }
      format.js { 
        
        flash.now[:notice]="Successfully deactivated advert"
        render :action => "activate.js.erb"
      }
    end
    end
  end
  def really_destroy
    @advert.destroy!
    respond_to do |format|
      format.html { redirect_to  adverts_url }
      format.js {flash.now[:notice]="Successfully destroyed advert"}
    end
  end

  def destroy
   
    @advert.destroy
    respond_to do |format|
      format.html { redirect_to  adverts_url }
      format.js {flash.now[:notice]="Your Ad has been cancelled"}
    end
  end

  def details
    @action="details"
    @advert.current_step=session[:advert_step]=@action
    if @advert.basics_saved
    @vehicle=@advert.vehicle
    @countries=Country.order(:name)
    @cities=City.order(:name)
    @states=State.order(:name)
    else
    respond_to do |format|
      format.html { 
        flash[:error]="Please add basic details first"
        redirect_to action: @advert.previous_step
      }
    end
    end
  end
   def features
    @action="features"
    @advert.current_step=session[:advert_step]=@action
    @vehicle=@advert.vehicle
  end
  def photos
    @action="photos"
    @advert.current_step=session[:advert_step]=@action
    @vehicle=@advert.vehicle
    @pictures=@vehicle.pictures.order(:position)
    @count=@pictures.count
    @max_pictures=7
  end
  def contact
    @action="contact"
    @advert.current_step=session[:advert_step]=@action
    @vehicle=@advert.vehicle
  end
  def checkout
    @action="checkout"
    @advert.current_step=session[:advert_step]=@action
    @vehicle=@advert.vehicle
    @order=@advert.order
  end
  def show_secondary_phone
    advert=Advert.with_deleted.find_by_uid(params[:id])
    user=advert.user
    @phone=user.secondary_phone
    @phone_type="secondary"
     respond_to do |format|
          format.js {
          	render :action => 'show_phone.js.erb'
          }
        end
  end
  def show_primary_phone
    advert=Advert.with_deleted.find_by_uid(params[:id])
    user=advert.user
    @phone=user.primary_phone
    @phone_type="primary"
       respond_to do |format|
          format.js {
            render :action => 'show_phone.js.erb'
          }
        end
  end

def preview
    @vehicle=@advert.vehicle
    @user=@vehicle.user
    @pictures=@vehicle.pictures
    @make=@vehicle.make
    @make_name=@make.name if @make
    @model_name=@vehicle.model_name
     respond_to do |format|
      format.html # preview.html.erb
      format.json { render json: @vehicle }
    end
 
end
  
    def init_gon(t_id)
    @makes=Make.where(:type_id=>t_id).order(:name)
    Rails.cache.fetch 'cached_gon' do
      @models=Model.order(:name)
      @series=Serie.all
      grouped_models_hash(@makes,@models,@series)
    end
    gon.grouped_models=Rails.cache.read 'cached_gon'
  end

  private
  def sort_column
    Advert.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end
   def sort_direction
      %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"
  end
def find_advert
    @advert=Advert.with_deleted.find_by_uid(params[:id])
    unless @advert.user==current_user
     respond_to do |format|
      format.html { 
        if request.referrer 
          redirect_to :back
        else
          redirect_to root_url
        end
        flash[:alert]= "You are not authorized to view this!"
      }
      format.json { head :no_content }
    end

    end
    end
 def modify(params)
    if params["vehicle_attributes"]
      params["vehicle_attributes"]["model_spec"]='' if params["vehicle_attributes"]["model_id"]!="0"
      params["vehicle_attributes"]["city_id"]=nil if params["vehicle_attributes"]["state_id"]==""
     
    end
    params
 end
end
