class PriceAlertsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do
    flash[:alert] = 'The object you tried to access does not exist'
    redirect_to :root
  end
  before_filter :authenticate_user!
  #before_filter :require_permission, only: :show
  layout :false
  respond_to :html

  def show
    @price_alert = current_user.price_alerts.find(params[:id])
    respond_with(@price_alert)
  end

  def create
    @price_alert = PriceAlert.new(params[:price_alert])
    if @price_alert.save
      Notifier.vehicle_price_updated(@price_alert).deliver
    end
    respond_with(@price_alert)
  end

end
