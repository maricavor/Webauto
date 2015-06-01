class PicturesController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :get_current_type

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
      flash.now[:notice] = "Successfully added image."
    else
      flash.now[:alert] = "Failed to upload image: "+@picture.errors.full_messages.join(', ')
    end
    else
      flash.now[:alert] = "You cannot have more than #{@max_pictures} photos on this account."
    end
  end

  def fail_upload
    flash.now[:alert] = "Failed to upload image "+params[:file]+": "+params[:error]
  end
  def update
    @picture = Picture.find(params[:id])
    if @picture.update_attributes(params[:picture])
      flash[:notice] = "Successfully updated picture."
      redirect_to @picture.vehicle
    else
      render :action => 'edit'
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
      format.html { redirect_to :back, :notice => "Successfully deleted image." }
      format.js {flash.now[:notice] = "Successfully deleted image."}
      format.json { head :no_content }
    end
  end
end