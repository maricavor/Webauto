class RegistrationsController < Devise::RegistrationsController
  def new
   @title=t("registrations.new.title")
   session[:omniauth]= nil if params[:with_password]
   super
  end
   def edit
    
    super
   end
    # POST /resource
  def create
    build_resource(sign_up_params)
    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up #if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" #if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      @validatable = devise_mapping.validatable?
      if @validatable
        @minimum_password_length = resource_class.password_length.min
      end
      flash[:error]=resource.errors.full_messages.first
      respond_with resource
    end
    session[:omniauth]= nil unless resource.new_record?
  end
  
 
  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    
      if resource.update_attributes(resource_params)
        set_flash_message :notice, :updated if is_navigational_format?
        sign_in resource_name, resource, :bypass => true
        respond_with resource, :location => dashboard_path #after_update_path_for(resource)
      else
        flash[:error]=resource.errors.full_messages.first
        respond_with resource
      end
  
  end

  def destroy
    resource.soft_delete
    set_flash_message :notice, :destroyed
    sign_out_and_redirect(resource)
  end
  private

  def build_resource(*args)
    super
    if session[:omniauth]
    resource.apply_omniauth(session[:omniauth])
    resource.valid?
  end
  end
end