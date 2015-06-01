class Search < ActiveRecord::Base
  extend FriendlyId
  attr_accessor :updating_name
  attr_accessible :updating_name,:adverts,:bt, :cl, :dt, :fpgt, :fplt, :ft, :keywords, :kmgt, :kmlt, :pwgt, :pwlt, :tm, :tp, :fields_attributes,:location,:region,:engine_size,:doors,:stgt,:stlt,:slug,:keywords,:user_id,:user_ip,:name,:updated_at,:yeargt,:yearlt,:is_dealer,:is_private,:features,:sort,:exception,:alert_freq
  has_many :fields, class_name: "MakeModelField",:dependent=>:destroy
  has_many :search_alerts,:dependent=>:destroy
  accepts_nested_attributes_for :fields, allow_destroy: true,reject_if: lambda {|attributes| attributes['make_name'].blank?}
  belongs_to :user
  belongs_to :type,:foreign_key=>"tp"
  validates :name, :presence => true,:on=>:update
  validates :name, :uniqueness => { :scope => :user_id,:case_sensitive => false },:on=>:update
  validate :search_unique,:on=>:update,:if=>:should_validate?
  validate :total_searches,:on=>:update,:if=>:should_validate?
  friendly_id :create_permalink, :use => :slugged
  after_create :update_popularity
  #after_update :create_search_alerts
  def create_permalink
    ## use current_user in model??????
    #if user_signed_in?  && !self.name.nil?
    #  slug=self.name
    #else
    slug=""
    self.fields.each do |f|
      slug+="#{f.make_name} " unless f.make_name.nil?
      slug+="#{f.model_name} " unless f.model_name.nil?
    end
    if slug==""
      slug+="all "
    end
 
    if self.is_dealer && !self.is_private
      slug+="dealer "
    elsif !self.is_dealer && self.is_private
      slug+="private "
    end
    slug+=" #{self.type.path_name}"
    return slug

    #end

  end
  def attributes_selected
    self.attributes.each_pair do |name, value|
      if %w(keywords bt fpgt fplt pwgt pwlt kmgt kmlt yeargt yearlt ft tm dt cl location doors stgt stlt engine_size).include? name
        unless (value.nil? || value=="")
          return true
        end
      end
    end
    return false
  end

  def to_gon_object
    mds = []
    self.fields.each { |f| mds.push([f.make_name,f.model_name])}
    {"vehicles"=>mds,"bt"=>self.bt,"ft"=>self.ft,"tm"=>self.tm,"dt"=>self.dt,"stgt"=>self.stgt,"stlt"=>self.stlt,"cl"=>self.cl,"location"=>self.location,"doors"=>self.doors,"region"=>self.region,"features"=>self.features}
  end
  def first_field_id
    self.fields.size>0 ? self.fields.first.id : nil
  end
  def to_comparison_hash
    h = {}
    self.attributes.each_pair do |key, value|
      unless ["id", "updated_at", "created_at","user_ip","user_id","slug","name","adverts"].include?(key)
        h[key] = value
      end
    end
    self.fields.each_with_index do |f,index|
      h["fields_#{index}"]=[f.make_name,f.model_name]
    end
    h
  end
  def search_unique
    user=self.user
    user.saved_searches.each do |s|
      if self.to_comparison_hash.eql?(s.to_comparison_hash)
        errors[:base] << "You have already saved this search. Please create a different search and try again."
        return
      end
    end
  end
  def total_searches
    user=self.user
    if user.saved_searches.count>9
      errors[:base] << 'You cannot save any more searches!'
      return
    end

  end
  
  def details
    d=[]
    self.fields.each do |f|
      d << f.make_name.to_s + " " + f.model_name.to_s
    end
    self.fpgt.present? ? min_price=ApplicationController.helpers.currency(self.fpgt) : min_price="Min"
    self.fplt.present? ? max_price=ApplicationController.helpers.currency(self.fplt) : max_price="Max"
    unless (min_price=="Min" && max_price=="Max")
      d << "#{min_price}-#{max_price}"
    end
    self.pwgt.present? ? min_power=self.pwgt : min_power="Min"
    self.pwlt.present? ? max_power=self.pwlt : max_power="Max"
    unless (min_power=="Min" && max_power=="Max")
      d << "#{min_power} kW-#{max_power} kW"
    end
    self.yeargt.present? ? min_year=self.yeargt.strftime('%Y') : min_year="Min"
    self.yearlt.present? ? max_year=self.yearlt.strftime('%Y') : max_year="Max"
    unless (min_year=="Min" && max_year=="Max")
      d << "#{min_year}-#{max_year}"
    end
    self.kmlt.present? ? max_km=ApplicationController.helpers.milage(self.kmlt) : max_km="Max"
    unless  max_km=="Max"
      d << "Min-#{max_km}"
    end
    d
  end

  def should_validate?
    self.updating_name=="false"
  end
  def update_popularity
    if self.bt.present?
      self.bt.split(",").each do |bt|
        bodytype=Bodytype.find(bt.to_i)
        if bodytype
          pop=bodytype.popularity
          bodytype.update_attributes(:popularity=>pop+1)
        end
      end
    end
  end

   def run(mode,sort=nil,page=nil,per_page=nil)
      keywords=self.keywords
      type= self.tp
      bodytype=self.bt
      fueltype=self.ft
      transmission=self.tm
      drivetype=self.dt
      colour=self.cl
      fpgt=self.fpgt
      fplt=self.fplt
      pwgt=self.pwgt
      pwlt=self.pwlt
      kmgt=self.kmgt
      kmlt=self.kmlt
      exception=self.exception
      country=self.location
      region=self.region
      yeargt=self.yeargt
      yearlt=self.yearlt
      stgt=self.stgt
      stlt=self.stlt
      doors=self.doors
      is_dealer=self.is_dealer
      is_private=self.is_private
      fields=self.fields
      features=self.features
      solr_search = Vehicle.search do
        fulltext keywords if keywords.present?
        if fields
        any_of do
          fields.each do |f|
            all_of do
              f.attributes.each_pair do |name,value|
                if name=="make_name"
                  with(:make_name,value) if value.present?
                end
                if name=="model_name"
                  if value.present?
                    any_of do
                      with(:model_name,value.split(","))
                      with(:serie_name).any_of(value.split(","))
                    end
                  end
                end
              end
            end
          end
        end
      end
        unless features.nil?
        features.split(",").each do |feat|
          if ["climate_control_id","service_history_id"].include?(feat)
          with(feat,"1")
          elsif feat=="seat_heating_count"
          with(feat).greater_than(0)
          else
          with(feat,true)
          end
        end
        end
        with(:type_id, type) if type.present?
        with(:bodytype_id,bodytype.split(",")) if bodytype.present?
        with(:price).greater_than_or_equal_to(fpgt) if fpgt.present?
        with(:price).less_than_or_equal_to(fplt) if fplt.present?
        with(:engine_power).greater_than_or_equal_to(pwgt) if pwgt.present?
        with(:engine_power).less_than_or_equal_to(pwlt) if pwlt.present?
        with(:odometer).greater_than_or_equal_to(kmgt) if kmgt.present?
        with(:odometer).less_than_or_equal_to(kmlt) if kmlt.present?
        with(:registered_at_date).greater_than_or_equal_to(yeargt) if yeargt.present?
        with(:registered_at_date).less_than_or_equal_to(yearlt) if yearlt.present?
        with(:seats).greater_than_or_equal_to(stgt) if stgt.present?
        with(:seats).less_than_or_equal_to(stlt) if stlt.present?
        with(:doors,doors.split(",")) if doors.present?
        with(:fueltype_id,fueltype.split(",")) if fueltype.present?
        with(:transmission_id,transmission.split(",")) if transmission.present?
        with(:drivetype_id,drivetype.split(",")) if drivetype.present?
        with(:colour_id,colour.split(",")) if colour.present?
        with(:country_id,country.split(",")) if country.present?
        without(:advert_id,nil)
        without(:id,exception) unless exception.nil?
        with(:activated,true)
        if region.present?
          any_of do
            with(:state,region.split(","))
            with(:city,region.split(","))
          end
        end
        any_of do
          with(:is_dealer,true) if is_dealer
          with(:is_dealer,false) if is_private
        end
      if mode=="normal"
        order_by(sort[0], sort[1])
        order_by(:created_at, :desc) if sort[0]=="popularity"
        paginate(:page => page, :per_page => per_page)
      else
        order_by(:created_at, :desc) 
      end
      end
        solr_search
    end

    def create_search_alerts
    if self.alert_freq!="No Alert" && self.alert_freq!=nil
    if self.name.present?
    results=self.run("background").results.map {|v| v.advert_id }.join(',')
    self.update_attributes(:adverts=>results)
    #self.adverts.split(',').each do |a_id|
    # unless SearchAlert.exists?(:advert_id => a_id, :search_id => self.id)
    #   alert=SearchAlert.new
    #   alert.advert_id=a_id
    #   alert.search_id=self.id
    #  alert.save!
    #end
    end
end
  end
end