class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_current_type,:get_compared_items

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  before_filter :set_gon,:set_i18n_locale_from_params
  def set_gon
    gon.object=nil
  end
  def get_compared_items
 
    ip_address=request.remote_ip
    session_hash= request.session_options[:id] 
    @compared_items=ComparedItem.where(:session_hash=>session_hash,:ip_address=>ip_address)
   
  end
  def get_current_type
    _type_id=session[:type_id] || 1
    @current_type=Type.find(_type_id)
  end
# Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end

 
  protected
  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.include?(params[:locale].to_sym)
        locale = params[:locale]
        cookies[:locale] = { :value => locale,:expires => 20.years.from_now.utc }
      else
        flash.now[:notice] ="#{params[:locale]} translation not available"
        logger.error flash.now[:notice]
      end
    end
    I18n.locale=locale || cookies[:locale]
  end
  def default_url_options
    { locale: I18n.locale }
  end


end