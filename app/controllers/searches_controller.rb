class SearchesController < ApplicationController
  before_filter :authenticate_user!, :only=>[:index,:show,:edit,:update]
  before_filter :find_search,:only=>[:destroy,:show,:update,:edit]
  before_filter :set_max_searches,:only=>[:remove_all,:index,:destroy]
  before_filter :set_search,:only=>[:new,:popular,:expensive]
  skip_before_filter :get_current_type,:get_compared_items,:only=>[:edit,:update]
  
  def index
    @title= t("searches.index.title")
    @searches=current_user.saved_searches.order("created_at desc")
    @count=@searches.count
    @search=Search.new
    
    #Resque.enqueue(AlertTestMailer,"Alert")
    
     
    
  end

  def new

    if params[:search]=="dealer"
      @search.is_dealer=true
      @search.is_private=false
     
      @search.dealers="#{params[:value]}"  if params[:value].present?
    elsif params[:search]=="private"
      @search.is_dealer=false
      @search.is_private=true
      
    elsif params[:search]=="make"
      @search.fields.build(:make_name=>params[:value])
    elsif params[:search]=="model"
      @search.fields.build(:make_name=>params[:value],:model_name=>params[:model])
    elsif params[:search]=="bodytype"
      @search.bt=params[:value]
    end
    @search.location=8
    @search.save!

    redirect_to send("search_#{@current_type.path_name}_path", @search,:sort=>"most_recent")

    #render :nothing => true
  end
  def popular
    @search.save!
    redirect_to send("search_#{@current_type.path_name}_path", @search,:sort=>"most_popular")
  end
  def expensive
    @search.save!
    redirect_to send("search_#{@current_type.path_name}_path", @search,:sort=>"price_high_to_low")
  end
  def similar

  end
  def show_more_deleted
    if params[:id]
      saved_item=SavedItem.find(params[:id])
      search=Search.new
      search.tp=saved_item.type_id
      search.tm=saved_item.transmission_id
      search.user_ip=request.remote_ip
      search.fields.build(make_name: saved_item.make_name,model_name: saved_item.model_name)
      search.save!
      redirect_to send("search_#{@current_type.path_name}_path", search,:sort=>"most_recent")
    else
      render :nothing=>true
    end

  end
  def show_more
    if params[:id]
      vehicle=Vehicle.with_deleted.find(params[:id])
      search=Search.new
      search.tp=vehicle.type_id
      search.tm=vehicle.transmission_id
      search.user_ip=request.remote_ip
      search.fields.build(make_name: vehicle.make_name,model_name: vehicle.model_name)
      search.save!
      redirect_to send("search_#{@current_type.path_name}_path", search,:sort=>"most_recent")
    else
      render :nothing=>true
    end

  end
  def remove_all
    @count=0
    current_user.searches.each do |search|
     search.name=nil
     search.save(:validate => false)
    end

    respond_to do |format|
      format.html {
        flash[:notice] = t("searches.remove_all")
        redirect_to searches_url
      }
      format.js { flash.now[:notice]= t("searches.remove_all") }
    end

  end

  def edit



  end
  def create
    @search = Search.new(modify(params[:search]))
    if @search.dealer_name
    dealer=User.find(@search.dealer_name)
    @search.dealers=dealer.id.to_s
    @search.save!
    redirect_to send("search_dealer_path", dealer.dealer_name,:search_id=>@search,:sort=>"most_recent")
    else
    @search.save!
    redirect_to send("search_#{@current_type.path_name}_path", @search,:sort=>"most_recent")
    end
  end


  def update

    if @search.update_attributes(modify(params[:search]))
      respond_to do |format|
        format.html {
          flash[:notice]= t("searches.saved")
          redirect_to searches_url
        }
        format.js {   
          flash.now[:notice]= t("searches.saved") 
        }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:error]= @search.errors.full_messages.first
          redirect_to searches_url
                    }
        format.js {

          flash.now[:error]= @search.errors.full_messages.first
          render 'fail_update'
        }
      end
    end
  end
  def show


    redirect_to search_vehicles_path(@search)

  end

  def destroy
    @search.name=nil
    @search.save(:validate => false)
    @search.search_alerts.destroy_all
    @searches=current_user.saved_searches.order("created_at desc")
    @count=@searches.count
    respond_to do |format|
      format.html { redirect_to searches_url, :notice => t("searches.removed")  }
      format.js { flash.now[:notice]= t("searches.removed") }
      format.json { head :no_content }
    end
  end
  private

  def set_search
    if current_user
      @search=current_user.searches.build
    else
      @search = Search.new
    end
    @search.tp=@current_type.id
    @search.user_ip=request.remote_ip
  end

  def modify(params)
    %w(bt ft tm dt cl doors region features dealers).each do |p|
      params[p]=params[p].reject(&:empty?).join(',') if params[p].present?
    end
    if params["fields_attributes"]
      new_fields_attributes={}
      temp={}
      params["fields_attributes"].each_pair do |key,value|
        make_name=value["make_name"]
        unless make_name.nil? or !make_name or make_name.empty?
          temp["#{make_name}"]=[] if temp["#{make_name}"].nil?
          temp["#{make_name}"]=temp["#{make_name}"]|value["model_name"].reject(&:empty?)
        end
      end
      temp.each_with_index do |(key,value),index|
        new_fields_attributes["#{index}"]={"make_name"=>"#{key}","model_name"=>"#{value.join(',')}"}
      end
      params["fields_attributes"]=new_fields_attributes
    end
  #if params["name"].present?# and @search.adverts.blank?
  #  params["adverts"]=@search.run("background").results.map {|v| v.advert_id }.join(',')
  #end
    #{"0"=>{"make_name"=>"BMW", "model_name"=>"116"}, "1"=>{"make_name"=>"Audi", "model_name"=>"A2,A3"}}
    #puts new_fields_attributes
    params
  end
  
  def find_in_hash(h,v)
    h.each_pair do |name,value|
      return true if value==v
    end
    return false
  end
  def find_search
    @search = Search.find(params[:id])
  end
  def set_max_searches
    @max_searches=10
  end
end