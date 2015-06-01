class GarageItemsController < ApplicationController
  before_filter :authenticate_user!
  # GET /garage_items
  # GET /garage_items.json
   before_filter :init_gon, :only=>[:new,:create,:edit,:update] 

  def index
     @user=current_user
     @solr_search = Vehicle.search do
      with(:user_id, @user) if @user
      with(:garage_item,true) 
      order_by(:created_at, :desc)
      paginate(:page => params[:page], :per_page => 10)
    end
    if @solr_search.total>0
      @vehicles = @solr_search.results
    else
      @vehicles=nil
      @title="No vehicles found"
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @vehicles }
    end
  end

  # GET /garage_items/1
  # GET /garage_items/1.json
  def show
    @vehicle = Vehicle.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @vehicle }
    end
  end

  # GET /garage_items/new
  # GET /garage_items/new.json
  def new
    @vehicle = Vehicle.new
    @type_id=1
    @bodytypes=Bodytype.where(:type_id=>1).order(:name)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @garage_item }
    end
  end

  # GET /garage_items/1/edit
  def edit
   @vehicle = Vehicle.find(params[:id])
   @type_id=1
   @bodytypes=Bodytype.where(:type_id=>1).order(:name)
   @picture=@vehicle.pictures.first || Picture.new
   gon.selected={"vehicles"=>[@vehicle.make.name,@vehicle.model_name,@vehicle.model_id]} if @vehicle.make
  
  end

  # POST /garage_items
  # POST /garage_items.json
  def create
    @vehicle = Vehicle.new(params[:vehicle])
    @bodytypes=Bodytype.where(:type_id=>1).order(:name)
     @type_id=1
    respond_to do |format|
      if @vehicle.save
        format.html { redirect_to garage_items_path, notice: 'Car was successfully added.' }
        format.json { render json: @vehicle, status: :created, location: @vehicle }
      else
        format.html { render action: "new" }
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /garage_items/1
  # PUT /garage_items/1.json
  def update
    @vehicle = Vehicle.find(params[:id])
    @bodytypes=Bodytype.where(:type_id=>1).order(:name)
     @type_id=1
    respond_to do |format|
      if @vehicle.update_attributes(params[:vehicle])
        format.html { redirect_to garage_items_path, notice: 'Vehicle was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit"}
        format.json { render json: @vehicle.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /garage_items/1
  # DELETE /garage_items/1.json
  def destroy
    @vehicle = Vehicle.find(params[:id])
    @vehicle.destroy

    respond_to do |format|
      format.html { redirect_to garage_items_url }
      format.js
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
end
