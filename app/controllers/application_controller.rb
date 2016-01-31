class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :get_current_type,:get_compared_items

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end
  before_filter :set_gon,:set_i18n_locale_from_params
  def set_gon
    gon.object=nil
  end
  def get_compared_items
 
    ip_address=request.remote_ip
    session_hash= request.session_options[:id] 
      @compared_items=ComparedItem.where(:session_hash=>session_hash,:ip_address=>ip_address)

  end
  def get_current_type
    _type_id=session[:type_id] || 1
    @current_type=Type.find(_type_id)
  end
# Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end
  def is_numeric?(obj)
    obj.to_s.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end
   def set_current_sort
    @sort_fields=[[t("search.most_recent"),"created_at desc","most_recent"],[t("search.most_popular"),"popularity desc","most_popular"],[t("search.price_high_low"),"price desc","price_high_to_low"],[t("search.price_low_high"),"price asc","price_low_to_high"],[t("search.make_model_a_z"),"make_model asc","make_model_asc"],[t("search.make_model_z_a"),"make_model desc","make_model_desc"],[t("search.kms_high_low"),"odometer desc","kms_high_to_low"],[t("search.kms_low_high"),"odometer asc","kms_low_to_high"],[t("search.year_high_low"),"registered_at_date desc","newest_first"],[t("search.year_low_high"),"registered_at_date asc","oldest_first"]]
    if params[:sort]
    unless is_numeric? params[:sort]
      sort=params[:sort] || "most_recent"
    else
      sort="most_recent"
    end
   else
     sort="most_recent"
     params[:sort]=sort
   end
    @current_sort=@sort_fields.detect{|s| s[2]==sort}

  end
    def get_property_records(t_id)
    @bodytypes=Bodytype.where(:type_id=>t_id).order(:name)
    @states=State.order(:name)
    @cities=City.order(:name)
  end
   def init_gon(t_id)
    @makes=Make.where(:type_id=>t_id).order(:name)
    Rails.cache.fetch 'cached_gon' do
      @models=Model.order(:name)
      @series=Serie.all
      grouped_models_hash(@makes,@models,@series)
    end
    gon.grouped_models=Rails.cache.read 'cached_gon'
  end
  protected
  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.include?(params[:locale].to_sym)
        locale = params[:locale]
        cookies[:locale] = { :value => locale,:expires => 20.years.from_now.utc }
      else
        flash.now[:notice] = t("translation_na",:locale=>params[:locale])
        logger.error flash.now[:notice]
      end
    end
    I18n.locale=locale || cookies[:locale]
  end
  def default_url_options
    { locale: I18n.locale }
  end


end