class InquiriesController < ApplicationController
  before_filter :find_vehicle
  def create
    @inquiry = Inquiry.new(params[:inquiry])
    unless params[:content].present? # honeypot check


      if @inquiry.deliver(@vehicle)
        respond_to do |format|
          format.html { redirect_to @vehicle, :notice => "Your message has been submitted. Thank you!" }
          format.js {
            flash.now[:notice] = "Your message has been submitted. Thank you!"
            render @inquiry.mode+'_create'
          }
        end

      else
        respond_to do |format|
          format.html { redirect_to @vehicle, :alert => @inquiry.errors.full_messages.to_sentence }
          format.js {
            flash.now[:alert] = @inquiry.errors.full_messages.to_sentence
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