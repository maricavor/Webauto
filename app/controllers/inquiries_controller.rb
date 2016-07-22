class InquiriesController < ApplicationController
  skip_before_filter :get_current_type,:get_compared_items
  def create
    @inquiry = Inquiry.new(params[:inquiry])
    if @inquiry.mode=="contact_dealer"
      obj=User.find(params[:user_id])
    else
      obj=Vehicle.find(params[:vehicle_id])
    end
    unless params[:content].present? # honeypot check
      if @inquiry.deliver(obj)
        respond_to do |format|
       
          format.js {
            flash.now[:notice] = t("inquiries.created")
            render @inquiry.mode+'_create'
          }
        end
      else
        respond_to do |format|
        
          format.js {
            flash.now[:alert] = @inquiry.errors.full_messages.first
            render 'fail_create'
          }
        end

      end
    end
  end
  
  
 
end