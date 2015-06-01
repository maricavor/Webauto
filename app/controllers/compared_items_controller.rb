class ComparedItemsController < ApplicationController
  # GET /compared_items
  # GET /compared_items.json
  def index
    @compared_items = ComparedItem.where(:session_hash=>request.session_options[:id]).last(4)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @compared_items }
    end
  end

  # GET /compared_items/1
  # GET /compared_items/1.json
  def show
    @compared_item = ComparedItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @compared_item }
    end
  end

  # GET /compared_items/new
  # GET /compared_items/new.json
  def new
    @compared_item = ComparedItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @compared_item }
    end
  end

  # GET /compared_items/1/edit
  def edit
    @compared_item = ComparedItem.find(params[:id])
  end

  # POST /compared_items
  # POST /compared_items.json
  def create
    @compared_item = ComparedItem.new(params[:vehicle_id])

    respond_to do |format|
      if @compared_item.save
        format.html { redirect_to @compared_item, notice: 'Compared item was successfully created.' }
        format.json { render json: @compared_item, status: :created, location: @compared_item }
      else
        format.html { render action: "new" }
        format.json { render json: @compared_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /compared_items/1
  # PUT /compared_items/1.json
  def update
    @compared_item = ComparedItem.find(params[:id])

    respond_to do |format|
      if @compared_item.update_attributes(params[:compared_item])
        format.html { redirect_to @compared_item, notice: 'Compared item was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @compared_item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /compared_items/1
  # DELETE /compared_items/1.json
  def destroy
    @compared_item = ComparedItem.find(params[:id])
    @compared_item.destroy
    respond_to do |format|
      format.html { redirect_to :back, :notice => "Successfully deleted item from compare list." }
      format.js { flash.now[:notice] =  "Successfully deleted item from compare list." }
      format.json { head :no_content }
    end
  
  end
end
