class DealerPicturesController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :get_current_type,:get_compared_items

  def create
    @picture = DealerPicture.new(params[:dealer_picture])
    if @picture.save
      flash.now[:notice] = t("dealer_pictures.success")
    else
      flash.now[:alert] = t("dealer_pictures.failure") + @picture.errors.full_messages.join(', ')
    end
   
  end

 
  

  def destroy
    @picture = DealerPicture.find(params[:id])
    @user=@picture.user
    @picture.destroy
    
     respond_to do |format|
      format.html { redirect_to :back, :notice => t("dealer_pictures.destroyed") }
      format.js {flash.now[:notice] = t("dealer_pictures.destroyed")  }
      format.json { head :no_content }
    end
  end
end