class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_filter :get_current_type,:get_compared_items
  def facebook
    #render :text => request.env["omniauth.auth"].to_yaml
    authenticate
  end
 
  def google_oauth2
    #render :text => request.env["omniauth.auth"].to_yaml
    authenticate
  end
  private
  def authenticate
    omniauth =  request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'],omniauth['uid'])
    if authentication
      flash[:notice]=t("omniauth.signed_in")
      sign_in_and_redirect authentication.user,:location=>root_path,:event => :authentication
    elsif current_user
      current_user.authentications.create(:provider=>omniauth['provider'],:uid=>omniauth['uid'])
      flash[:notice]=t("omniauth.success")
      #set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
      redirect_to profile_path
    else
      user=User.new
      user.apply_omniauth(omniauth)
    if user.save
      flash[:notice]=t("omniauth.signed_in")
      sign_in_and_redirect(:user,user)
    else
      session[:omniauth]=omniauth.except('extra')
      redirect_to new_user_registration_url
    end
  end
  end
end