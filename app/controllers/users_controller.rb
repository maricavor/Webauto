class UsersController < ApplicationController
  before_filter :authenticate_user!,:except=>[:show_phone]
  before_filter :correct_user, only: [:update]
  skip_before_filter :get_current_type,:get_compared_items, :only=>[:show_phone]

  def show
    @title=t("users.dashboard.title")
    #@user = User.find(params[:id])
    #@user = !params[:id].nil? ? User.find(params[:id]) : current_user
    @user=current_user
    @saved_items=@user.saved_items.last(4)
    @saved_searches=@user.saved_searches.last(3)
    @last_searches=@user.searches.order("created_at desc").last(5)


   end
  
  
  def edit
    @title=t("users.settings.title")
    @user=current_user
  end
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to settings_path, :notice => t("users.updated")
    else
      redirect_to settings_path, :alert => t("users.not_saved")
    end
  end
 

  def destroy
    authorize! :destroy, @user, :message => t("users.not_authorized")
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice =>  t("users.deleted")
    else
      redirect_to users_path, :notice =>  t("users.not_deleted")
    end
  end
  
  def ads
    
    @user=current_user
    #@vehicles=@user.vehicles

    @solr_search = Vehicle.search do
      with(:user_id, @user) if @user
      without(:advert,nil) 
      order_by(:created_at, :desc)
      paginate(:page => params[:page], :per_page => 10)
    end

    if @solr_search.total>0
      @vehicles = @solr_search.results
 
    else
      @vehicles=nil
      @title=t("users.nothing")
    end
  end
   def show_phone
    user=User.find(params[:id])
    @primary_phone=user.phone1
    @secondary_phone=user.phone2
    render 'users/show_phone', :formats => [:js]
  end

  private


 # Confirms the correct user.#########
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end