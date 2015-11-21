class DealersController < ApplicationController
  before_filter :set_params,:only=>[:show]
  def set_params
    @row_size=4
    @per_page=16
  end
  def index
     @title=t("dealers.index.title")
     @dealers = User.search(modify(params)).order("company_name").page(params[:page]).per(1)
      _country=Country.find(8)
      _states=_country.states
      _cities=_country.cities
      @regions=_states.map{|p| [ p.name.upcase, p.name ] }+_cities.map{|p| [ p.name, p.name ] } 
     gon.selected={:vehicles=>[[nil,nil]],:region=>params[:region]}
  end

  def show
     set_current_sort
     @dealer = User.find(params[:id])
     @title=@dealer.name+ " - Webauto.ee"
     if params[:search_id]
     @search = Search.find(params[:search_id])
     else
     @search = Search.new(:tp=>"#{@current_type.id}",:dealers=>"#{@dealer.id}",:is_dealer=>"1")
     end
     @search.fields.build if @search.fields.size==0
     @inquiry=Inquiry.new
     @bodytypes=Bodytype.where(:type_id=>@current_type.id).order(:name)
     @makes=Make.where(:type_id=>@current_type.id).order(:name)
     Rails.cache.fetch 'cached_gon' do
      @models=Model.order(:name)
      @series=Serie.all
      grouped_models_hash(@makes,@models,@series)
     end
     gon.grouped_models=Rails.cache.read 'cached_gon'
     @solr_search=@search.run("normal",@current_sort[1].split(' '),params[:page],@per_page)
     total=@solr_search.total 
      if total>0
        @vehicles = @solr_search.results
      else
        @vehicles=[]
        @title=t("dealers.index.nothing")
      end
     gon.selected=@search.to_gon_object
  end
  
   private

  def modify(params)
   %w(region).each do |p|
      params[p]=params[p].reject(&:empty?).join(",") if params[p].present?
    end
    params
  end
  

end
