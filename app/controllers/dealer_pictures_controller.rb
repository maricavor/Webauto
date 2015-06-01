class DealerPicturesController < ApplicationController
  before_filter :authenticate_user!


  def create
    @picture = DealerPicture.new(params[:dealer_picture])
    if @picture.save
      flash.now[:notice] = "Successfully added image."
    else
      flash.now[:alert] = "Failed to upload image: "+@picture.errors.full_messages.join(', ')
    end
   
  end

 
  def update
    @picture = DealerPicture.find(params[:id])
    if @picture.update_attributes(params[:dealer_picture])
      flash[:notice] = "Successfully updated picture."
      redirect_to @picture.user
    else
      render :action => 'edit'
    end
  end

  def destroy
    @picture = DealerPicture.find(params[:id])
    @user=@picture.user
    @picture.destroy
    
     respond_to do |format|
      format.html { redirect_to :back, :notice => "Successfully deleted image." }
      format.js {flash.now[:notice] = "Successfully deleted image."}
      format.json { head :no_content }
    end
  end
end