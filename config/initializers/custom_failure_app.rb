class CustomFailureApp < Devise::FailureApp
  def redirect_url
    if request.xhr?
      send(:"new_#{scope}_session_path", :format => :js)
    else
      super
    end
  end
end