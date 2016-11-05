class ReviewsController < ApplicationController
  before_filter :authenticate_user!, :only=>[:new,:create,:confirmation,:destroy,:add]
  before_filter :set_review, only: [:details,:show,:destroy,:ads]
  before_filter :except=>[:show,:details,:destroy] do |controller|
    controller.init_gon(1)
  end
  respond_to :html
  def index
    @title=t("reviews.index.title")
    @per=10
    set_current_sort
    total_reviews = Review.search(params).order(@current_sort[1])
    @reviews_count=total_reviews.count
    @reviews = total_reviews.page(params[:page]).per(@per)
    @bodytypes=Bodytype.where(:type_id=>1)
     gon.selected={:vehicles=>[[params[:make],params[:model]]],:bt=>params[:bt],:tm=>params[:tm],:yeargt=>params[:yeargt],:yearlt=>params[:yearlt]}
   
  end
  def add
    flash[:info]=t("reviews.new.info")
    redirect_to garage_items_path
   
  end
  def show
    @title=t("reviews.details.title", :vehicle_name=>@review.vehicle_name)+" - Webauto.ee"
    if @review.accepted
    respond_with(@review)
  else
    redirect_to :back
    #flash[:alert]="This review is not accepted or does not exist"
  end
  end
  def details
    @title=t("reviews.details.title", :vehicle_name=>@review.vehicle_name)+" - Webauto.ee"
    if @review.accepted
    respond_with(@review)
  else
    redirect_to :back
    #flash[:alert]="This review is not accepted or does not exist"
  end
  end
 
  def new
    @title=t("reviews.new.title")
    @exp_max_length=Review.validators_on(:experience).first.options[:maximum]
    #@title_max_length=Review.validators_on(:title).first.options[:maximum]
    @review=Review.new
    if params[:id]
    @vehicle=Vehicle.find(params[:id])
    @garage_item=@vehicle.garage_item
    if @vehicle.review
      respond_to do |format|
      format.html {
      redirect_to :back
      flash[:alert]=t("reviews.new.already_reviewed")
    }
  end
  else
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @review }
    end
      end
    else
      respond_to do |format|
      format.html {
      redirect_to reviews_path
      flash[:alert]=t("reviews.new.no_selected")
    }
    end
end
  end

 
  def confirmation
    @title=t("reviews.confirmation.title")
  end
  
  def create
    @review = Review.new(params[:review])
    @exp_max_length=Review.validators_on(:experience).first.options[:maximum]
    #@title_max_length=Review.validators_on(:title).first.options[:maximum]
    if @review.vehicle
    @vehicle=@review.vehicle
    @garage_item=@vehicle.garage_item
     end
    @bodytypes=Bodytype.where(:type_id=>@current_type.id)
    if @review.save
      respond_to do |format|
      format.html { 
        flash[:notice]= t("reviews.new.success")
        redirect_to confirmation_reviews_path 
      }
      end
    else
       respond_to do |format|
      format.html { 
        flash[:alert]=@review.errors.full_messages.first
        render action: "new" 
      }
     end
    end
  end
 
  def destroy
    @review.destroy
    respond_with(@review)
  end
  def set_current_sort
   @sort_fields=[[t("search.date_newest_first"),"created_at desc","newest"],[t("search.date_oldest_first"),"created_at asc","oldest"],[t("search.rating_highest_first"),"overall desc","most_rated"],[t("search.rating_lowest_first"),"overall asc","less_rated"]]
   if params[:sort]
   unless is_numeric? params[:sort]
     sort=params[:sort] || "newest"
   else
     sort="newest"
   end
  else
    sort="newest"
    params[:sort]=sort
  end
   @current_sort=@sort_fields.detect{|s| s[2]==sort}

 end
 def ads
    id=@review.vehicle_id
    model_name=@review.model_name
    make_name= @review.make_name 
    type_id=1
 
     @solr_search = Vehicle.search do
       with(:model_name,model_name) 
       with(:make_name,make_name)   
       with(:type_id, type_id) 
       with(:country_id,8)
       #with(:registered_at_date).greater_than_or_equal_to(DateTime.new(year-2,1,1))
       #with(:registered_at_date).less_than_or_equal_to(DateTime.new(year+2,1,1)) 
       without(:advert_id,nil)
       without(:id,id)
       with(:activated,true)
       order_by(:ad_activated_at, :desc)
       paginate(:page => 1, :per_page => 6)
     end
     @total=@solr_search.total
     if @total>0
       @vehicles = @solr_search.results
     else
       @vehicles=nil
     end
  
 end
  private
    def set_review
      @review = Review.find(params[:id])
    end
   

  
end
