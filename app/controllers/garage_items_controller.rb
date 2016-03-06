class GarageItemsController < ApplicationController
  before_filter :authenticate_user!
  # GET /garage_items
  # GET /garage_items.json
   before_filter :init_gon, :only=>[:new,:create,:edit,:update] 
   before_filter :set_max_items,:only=>[:index,:destroy]
  def index
    @title= "My Garage - Webauto.ee"
    @garage_items=current_user.garage_items.order("created_at desc")
    @count=@garage_items.count

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @vehicles }
    end
  end

 
 
  # GET /garage_items/new
  # GET /garage_items/new.json
  def new
    @vehicle=Vehicle.new
    @vehicle.build_garage_item
    @bodytypes=Bodytype.where(:type_id=>1)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @vehicle }
    end
  end

  # GET /garage_items/1/edit
  def edit
   @garage_item = current_user.garage_items.find(params[:id])
   @vehicle = @garage_item.vehicle
   @bodytypes=Bodytype.where(:type_id=>1)
   gon.selected={"vehicles"=>[@vehicle.make.name,@vehicle.model_name,@vehicle.model_id]} if @vehicle.make
  
  end

  # POST /garage_items
  # POST /garage_items.json
  def create
    @vehicle = Vehicle.new(modify(params[:vehicle]))
    @bodytypes=Bodytype.where(:type_id=>1)
   
 
    gon.selected={"vehicles"=>[nil,nil,@vehicle.model_id]} 
    respond_to do |format|
      if @vehicle.save
        
        format.html { redirect_to garage_items_path, notice: 'Car was successfully added.' }
        format.json { render json: @vehicle, status: :created, location: @vehicle }
      else
        format.html { 
          flash[:alert]=@vehicle.errors.full_messages.first
          render action: "new" 
        }
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /garage_items/1
  # PUT /garage_items/1.json
  def update
    @garage_item = current_user.garage_items.find(params[:id])
    @vehicle = @garage_item.vehicle
    @bodytypes=Bodytype.where(:type_id=>1)
    @type_id=1
    gon.selected={"vehicles"=>[@vehicle.make_name,@vehicle.model_name,@vehicle.model_id]} if @vehicle.make
    respond_to do |format|
      if @vehicle.update_attributes(modify(params[:vehicle]))
        format.html { redirect_to garage_items_path, notice: 'Vehicle was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { 
          flash[:alert]=@vehicle.errors.full_messages.first
          render action: "edit"
        }
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /garage_items/1
  # DELETE /garage_items/1.json
  def destroy
    @garage_item = current_user.garage_items.find(params[:id])
    @vehicle=@garage_item.vehicle
    @garage_item.destroy
    unless @vehicle.advert
    if @vehicle.pictures.size>0
    @picture=@vehicle.pictures.first
    @picture.destroy
    end
    @vehicle.really_destroy!
  end
    @garage_items=current_user.garage_items
    @count=@garage_items.count
    respond_to do |format|
      format.html { redirect_to garage_items_url,:notice => t("garage_items.destroyed") }
      format.js {flash.now[:notice]= t("garage_items.destroyed")}
      format.json { head :no_content }
    end
  
  end
    def init_gon
    @makes=Make.where(:type_id=>1).order(:name)
    Rails.cache.fetch 'cached_gon' do
      @models=Model.order(:name)
      @series=Serie.all
      grouped_models_hash(@makes,@models,@series)
    end
    gon.grouped_models=Rails.cache.read 'cached_gon'
  end
  private
  def set_max_items
    @max_items=GarageItem::MAX_ITEMS
  end
  def modify(params)
     if params["pictures_attributes"]
       params["pictures_attributes"]={} if params["pictures_attributes"]["0"]["file"].nil?
     end
     params
  end
end
