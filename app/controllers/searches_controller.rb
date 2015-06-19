class SearchesController < ApplicationController
  before_filter :authenticate_user!, :only=>[:index,:show,:edit,:update]
  before_filter :find_search,:only=>[:destroy,:show,:update,:edit]
  before_filter :set_max_searches,:only=>[:remove_all,:index]
  before_filter :set_search,:only=>[:new,:popular,:expensive]
  skip_before_filter :get_current_type,:only=>[:edit,:update]
  
  def index
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
  def show_more
    if params[:advert_id]
      advert=Advert.with_deleted.find_by_uid(params[:advert_id])
      vehicle=advert.vehicle
      search=Search.new
      search.tp=vehicle.type_id
      search.tm=vehicle.transmission_id
      search.user_ip=request.remote_ip
      search.fields.build(make_name: vehicle.make.name,model_name: vehicle.model.name)
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
        flash[:notice] = "You have removed all searches!"
        redirect_to searches_url
      }
      format.js { flash.now[:notice]= "You have removed all searches!" }
    end

  end

  def edit



  end
  def create
    @search = Search.new(modify(params[:search]))
    @search.save!
    redirect_to send("search_#{@current_type.path_name}_path", @search,:sort=>"most_recent")
  end


  def update

    if @search.update_attributes(modify(params[:search]))
      respond_to do |format|
        format.html {
          flash[:notice]= 'Your search has been saved!'
          redirect_to searches_url
        }
        format.js {   
          flash.now[:notice]= 'Your search has been saved!' 
        }
      end
    else
      respond_to do |format|
        format.html { 
          flash[:error]= 'Your search has not been saved!'
                      redirect_to searches_url
                    }
        format.js {

          flash.now[:error]= @search.errors.full_messages.to_sentence
          render 'fail_update.js.erb'
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
    @max_searches=10
    respond_to do |format|
      format.html { redirect_to searches_url, :notice => 'Search deleted'  }
      format.js
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
    %w(bt ft tm dt cl location doors region features dealers).each do |p|
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
  if params["name"].present? and @search.adverts.blank?
    params["adverts"]=@search.run("background").results.map {|v| v.advert_id }.join(',')
  end
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