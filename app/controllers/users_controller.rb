class UsersController < ApplicationController
  before_filter :authenticate_user!,:except=>[:index,:contact]
  before_filter :correct_user,   only: [:update]
  def index
    #authorize! :index, @user, :message => 'Not authorized as an administrator.'
     @title="Webauto | Find a car dealership in Estonia"
     @dealers = User.search(modify(params)).order("company_name").page(params[:page]).per(10)
      _country=Country.find(8)
      _states=_country.states
      _cities=_country.cities
      @regions=_states.map{|p| [ p.name.upcase, p.name ] }+_cities.map{|p| [ p.name, p.name ] } 
     gon.selected={:vehicles=>[[nil,nil]],:region=>params[:region]}
  end

  def show
    #@user = User.find(params[:id])
    #@user = !params[:id].nil? ? User.find(params[:id]) : current_user
    @user=current_user
    @saved_items=@user.saved_items.last(3)
    @saved_searches=@user.saved_searches.last(3)
    @last_searches=@user.searches.order("created_at desc").last(3)


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
  def contact
   @dealer = User.find(params[:user_id])
   @inquiry = Inquiry.new(params[:inquiry])
    unless params[:content].present? # honeypot check
      if @inquiry.deliver(@dealer)
        respond_to do |format|
          format.html { redirect_to :back, :notice => "Your message has been submitted. Thank you!" }
          format.js {
            flash.now[:notice] = "Your message has been submitted. Thank you!"
          }
        end

      else
        respond_to do |format|
          format.html { redirect_to :back, :alert => @inquiry.errors.full_messages.to_sentence }
          format.js {
            flash.now[:alert] = @inquiry.errors.full_messages.to_sentence
            render 'fail_contact'
          }
        end

      end
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
  private

  def modify(params)
   %w(region).each do |p|
      params[p]=params[p].reject(&:empty?).join(",") if params[p].present?
    end
    params
  end
 # Confirms the correct user.
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end