class Advert < ActiveRecord::Base
  AD_TYPES = [ "free", "standard"]
  acts_as_paranoid
  attr_accessible :contact_number,:make_model,:status,:email, :activated,:sold, :price, :secondary_number, :type, :uid,:vehicle_attributes,:deleted_at,:basics_saved,:details_saved,:features_saved,:photos_saved,:contact_saved,:ad_type,:user_id,:type_id,:delete_reason_id
  attr_writer :current_step
  has_one :vehicle#,:dependent => :destroy
  has_one :order
  has_one :type
  belongs_to :user
  accepts_nested_attributes_for :vehicle#, reject_if: :price_invalid
  #validate :vehicle_price_valid, :if=>:contact?
  ##
  before_create :generate_uid,:set_status
  before_update :set_status
  after_destroy :check_status_and_inform,:deactivate
  after_create :create_line_items
 
  #before_destroy :deactivate
  validates :ad_type, inclusion: AD_TYPES,:on => :create
 def vehicle
  Vehicle.unscoped { super }
end

  def to_param
   self.uid
  end
   def current_step
    @current_step || steps.first
  end
   def steps
    %w[edit details features photos contact checkout]
  end

  def details?
    self.current_step == "details"
  end
  def features?
    self.current_step == "features"
  end
  def photos?
    self.current_step == "photos"
  end
  def edit?
    self.current_step == "edit"
  end
  def contact?
    self.current_step == "contact"
  end
  def checkout?
    self.current_step == "checkout"
  end
  def basics_and_no_model?
    self.current_step == "edit" && self.model_id==0
  end
  def next_step
    self.current_step = steps[steps.index(current_step)+1]
  end

  def previous_step
    self.current_step = steps[steps.index(current_step)-1]
  end

  def first_step?
    current_step == steps.first
  end

  def last_step?
    current_step == steps.last
  end

  def all_valid?
    steps.all? do |step|
      self.current_step = step
      valid?
    end
  end
  def unfinished?
   if self.basics_saved==false || self.details_saved==false || self.features_saved==false || self.photos_saved==false || self.contact_saved==false
   return true
   end
   return false
  end
  def delete_reason
    I18n.t('ad_delete_reasons').find { |d| d["id"]==self.delete_reason_id }["name"] if self.delete_reason_id.present?
  end
  def alert_price_update
  if self.activated?
    Resque.enqueue(PriceUpdateMailer, self.id)
  end
  end
  private
  def vehicle_price_valid
     errors.add(:base,"Price wrong")  unless vehicle.price =~ /\A\d+(?:\.\d{0,2})?\z/
  end

  def price_invalid(attributes)
    attributes[:price].blank? #=~ /\A\d+(?:\.\d{0,2})?\z/
  end

  def generate_uid
    record = true
    while record
      random = Array.new(7){rand(7)}.join
      record = Advert.find(:first, :conditions => ["uid = ?", random])
    end
    self.uid = random
  end
  def deactivate
 if self.status!="cancelled"
    #Rails.logger.info "******************deactivate"
    self.activated=false
    self.status="cancelled"
    self.save(validate: false)
 end
  end

  def set_status
    #Rails.logger.info "******************set status and make model"
  
    
   
 
    if self.deleted?
      self.status="cancelled"
    else
    if self.activated?
      self.status="activated"
    elsif self.unfinished?
      self.status="unfinished" 
      else
      self.status="not_activated"
    end
    end
  
  end
  def check_status_and_inform
      Resque.enqueue(SoldMailer, self.id)
  end
  def create_line_items
    if self.ad_type=="free"
     service=Service.find(2)
   else
     service=Service.find(1)
   end
     
     order=self.create_order!
     order.line_items.create!(service_id: service.id)
    
 
  
  end
 
end
