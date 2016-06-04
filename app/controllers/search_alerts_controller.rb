class SearchAlertsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound do
    flash[:alert] = 'The object you tried to access does not exist'
    redirect_to :root
  end
  before_filter :authenticate_user!
  #before_filter :require_permission, only: :show
  layout :false
  respond_to :html

 
  def show
    @search_alert = current_user.search_alerts.find(params[:id])
    respond_with(@search_alert)
  end

 

  def create
    @search_alert = SearchAlert.new(params[:search_alert])
    if @search_alert.save
    Notifier.adverts_created(@search_alert).deliver
    end
    respond_with(@search_alert)
  end




end
