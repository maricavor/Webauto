class UsersController < ApplicationController
  before_filter :authenticate_user!,:except=>[:index]

  def index
    #authorize! :index, @user, :message => 'Not authorized as an administrator.'
    @users = User.where(:is_dealer=>true)
  end

  def show
    #@user = User.find(params[:id])
    #@user = !params[:id].nil? ? User.find(params[:id]) : current_user
    @user=current_user
    @saved_items=@user.saved_items.last(3)
    @saved_searches=@user.saved_searches.last(3)
    @last_searches=@user.searches.order("created_at desc").last(3)


   end
   def show_phone


   end
  def edit
    @user=current_user

  end
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(params[:user])
      redirect_to settings_path, :notice => "Settings updated."
    else
      redirect_to settings_path, :alert => "Unable to save settings."
    end
  end


  def destroy
    authorize! :destroy, @user, :message => 'Not authorized as an administrator.'
    user = User.find(params[:id])
    unless user == current_user
      user.destroy
      redirect_to users_path, :notice => "User deleted."
    else
      redirect_to users_path, :notice => "Can't delete yourself."
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
      @title="No vehicles found"
    end
  end

end