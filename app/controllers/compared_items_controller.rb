class ComparedItemsController < ApplicationController
  # GET /compared_items
  # GET /compared_items.json
  def index
    @compared_items = ComparedItem.where(:session_hash=>request.session_options[:id]).last(4)
    #@compared_items=_compared_items.map {|ci| ci unless ci.vehicle.nil?}
    @title="Compare Vehicles - Webauto.ee"
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @compared_items }
    end
  end


  # DELETE /compared_items/1
  # DELETE /compared_items/1.json
  def destroy
    @compared_item = ComparedItem.find(params[:id])
    @compared_item.destroy
    respond_to do |format|
      format.html { redirect_to :back, :notice => t("compared_items.deleted") }
      format.js { flash.now[:notice] =  t("compared_items.deleted") }
      format.json { head :no_content }
    end
  
  end
end
