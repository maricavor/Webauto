class SessionsController < Devise::SessionsController
  def new
  	@title=t("sessions.new.title")
  	super
  end

  def create
  	self.resource = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
     #if !session[:return_to].blank?
     # redirect_to session[:return_to]
     # session[:return_to] = nil
    #else
    respond_with resource, location: after_sign_in_path_for(resource)
  end
end
