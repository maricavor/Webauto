class PicturesController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :get_current_type,:get_compared_items

  def create
    # @picture =Picture.new(params[:picture])
    # @picture.position=100
    # @picture.save!
    ############################################
    @picture = Picture.new(params[:picture])
    @vehicle=@picture.vehicle
    @pictures=Picture.where(:vehicle_id=>@vehicle.id).order(:position)
    @count=@pictures.count
    @max_pictures=7
  
    if @count<@max_pictures
    if @picture.save
      @count+=1
      flash.now[:notice] = t("pictures.added")
    else
      flash.now[:alert] = t("pictures.failure") + @picture.errors.full_messages.join(', ')
    end
    else
      flash.now[:alert] = t("pictures.cannot_have",:max=>@max_pictures)
    end
  end

  def fail_upload
    flash.now[:alert] = t("pictures.failed_to_upload",:file=>params[:file],:error=>params[:error])
  end
  def update
    @picture = Picture.find(params[:id])
    @vehicle=@picture.vehicle
    if @picture.update_attributes(params[:picture])
      flash.now[:notice] = t("pictures.updated")
      
    else
      flash.now[:alert] = t("pictures.failure") + @picture.errors.full_messages.join(', ')
    end
  end

  def destroy
    @picture = Picture.find(params[:id])
    @vehicle=@picture.vehicle
    @picture.destroy
    @pictures=Picture.where(:vehicle_id=>@vehicle.id).order(:position)
    @max_pictures=7
    @count=@pictures.count
 
  
     respond_to do |format|
      format.html { redirect_to :back, :notice => t("pictures.destroyed") }
      format.js {flash.now[:notice] = t("pictures.destroyed") }
      format.json { head :no_content }
    end
  end
end