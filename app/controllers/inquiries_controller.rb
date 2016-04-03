class InquiriesController < ApplicationController
  before_filter :find_vehicle,:only=>[:create]
  skip_before_filter :get_current_type,:get_compared_items
  def create
    @inquiry = Inquiry.new(params[:inquiry])
    unless params[:content].present? # honeypot check


      if @inquiry.deliver(@vehicle)
        respond_to do |format|
          format.html { redirect_to @vehicle, :notice => t("inquiries.create") }
          format.js {
            flash.now[:notice] = t("inquiries.create")
            render @inquiry.mode+'_create'
          }
        end

      else
        respond_to do |format|
          format.html { redirect_to @vehicle, :alert => @inquiry.errors.full_messages.first }
          format.js {
            flash.now[:alert] = @inquiry.errors.full_messages.first
            render @inquiry.mode+'_fail_create'
          }
        end

      end
    end
  end
  
  
  private

  def find_vehicle
    @vehicle=Vehicle.find(params[:vehicle_id])
  end
end