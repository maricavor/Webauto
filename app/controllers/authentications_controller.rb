class AuthenticationsController < ApplicationController
  before_filter :authenticate_user!, :only=>[:destroy]
  skip_before_filter :get_current_type,:get_compared_items
  def destroy
    @authentication = current_user.authentications.find(params[:id])
    @authentication.destroy
     respond_to do |format|
      format.html { 
      flash[:notice]= t("authentications.auth_destroyed")
      redirect_to profile_path
     }
      format.js {
        flash.now[:notice]= t("authentications.auth_destroyed")
      }
      format.json { head :no_content }
    end
    
  end
end
