class Review < ActiveRecord::Base
  attr_accessor :declaration, :ownership_id
  attr_accessible :vehicle_id, :bodytype_id, :make_id, :model_id, :model_spec, :transmission_id,:engine_size,:engine_power,:fueltype_id,:registered_at,:badge, :series,:odometer,:how_well,:first_owner,:how_well_other, :how_long, :performance, :practicality, :reliability, :running_costs,:overall, :title, :experience, :a_to_b, :first_car,:outdoors, :weekend,:offroading,:holiday,:extra_car, :job,:family_car,:racing,:towing,:showing, :declaration,:like1, :like2, :like3, :dislike1, :dislike2, :dislike3,:first_name, :user_id, :ownership_id,:accepted
  belongs_to :vehicle
  belongs_to :user
  belongs_to :bodytype
  belongs_to :make
  belongs_to :model
  belongs_to :fueltype
  validate :validate_how_well, :if=> :owned_or_drove?
  #validates :how_well_other, :presence => true, :if=> :other?
  validate :validate_how_long
  validate :validate_what_for
  #validate :validate_likes
  #validate :validate_dislikes

  #validates :title, length: {maximum: 70, minimum: 10}
  validate :validate_overall
  validates :experience, length: {maximum: 2000, minimum: 100}
  validate :experience_length
  validates :first_name, :presence => true
  validate :validate_declaration,:on=>:create
  translates :experience, :fallbacks_for_empty_translations => true
  globalize_accessors :locales => [:et, :en], :attributes => [:experience]
  def to_param
    if registered_at.present?
      "#{id} #{make_name} #{model_name} #{registered_at_year}".parameterize
    else
      "#{id} #{make_name} #{model_name}".parameterize
    end
  end
def self.search(search_params)
  reviews=Review.where(:accepted=>true)
  if search_params
    if search_params[:bt].present?
      reviews=reviews.where("bodytype_id = ?", search_params[:bt]) 
    end
  if search_params[:make].present?
    reviews=reviews.joins(:make).where(:makes=>{:name=>search_params[:make]}) 
  end
  if search_params[:model].present?
    reviews=reviews.joins(:model).where(:models=>{:name=>search_params[:model]}) 
  end
  if search_params[:yeargt].present?
    reviews=reviews.where("registered_at_date >= ?", search_params[:yeargt]) 
  end
  if search_params[:yearlt].present?
    reviews=reviews.where("registered_at_date <= ?", search_params[:yearlt]) 
  end
  if search_params[:tm].present?
    reviews=reviews.where("transmission_id = ?", search_params[:tm]) 
  end
  end
  reviews
end
def transmission
  I18n.t('transmissions').find { |c| c["id"]==self.transmission_id }["name"] if self.transmission_id.present?
end
def like_dislike_value(id)
    I18n.t('likes_dislikes').find { |c| c["id"]==id }["name"] 
end
def vehicle_name
  n="#{self.registered_at_year} #{self.make_name} #{self.model_name}"
  n+=" #{self.badge}" if self.badge.present?
  n
end
def engine_name
  n=""
  n+=" #{self.engine_size} L" if self.engine_size.present?
  n+=" #{self.engine_power} kW" if self.engine_power.present?
  n+=" #{self.fueltype_value}" if self.fueltype_id.present?
  n+=" #{self.transmission}" if self.transmission_id.present?
  n
end
def registered_at_year
  self.registered_at[/(\d{4})/] if self.registered_at.present?
end
def registered_at_date
 DateTime.parse(self.registered_at) if self.registered_at.present?
end
def model_name
  if model
    self.model.name
  else
    self.model_spec
  end
end
def make_name
  if self.make
    self.make.name
  else
    ""
  end
end
def odometer_value
  self.odometer.to_s + " km"
end
def fueltype
  I18n.t('fueltypes').find { |c| c["id"]==self.fueltype_id }["name"] if self.fueltype_id.present?
end
def fueltype_value
 self.fueltype ? "#{self.fueltype}" : "&nbsp;".html_safe
end
def how_well_value
  if self.how_well.present?
  if self.how_well==5
    hw=self.how_well_other
  else
    hw=I18n.t('how_well').find { |c| c["id"]==self.how_well }["name"]
  end
else
    hw=I18n.t('reviews.details.own')
end
end
def how_long_value
  I18n.t('how_long').find { |c| c["id"]==self.how_long }["name"] 
end
def what_for_value
  what_for=[]
  I18n.t('what_for').each do |wf|
    if self[wf["prop"]]==true
      what_for << wf["name"]
    end
  end
  what_for.join(", ")
end
def recommend_value
  self.recommend ? I18n.t('reviews.new.yess') : I18n.t('reviews.new.noo')
end
  private
  def validate_declaration
    if self.declaration=='0'
      errors.add(:_,I18n.t("reviews.new.validate_declaration"))
    end
  end
  def validate_how_well
    unless self.how_well.present?
      errors.add(:_,I18n.t("reviews.details.how_well")+"?")
    end
  end
  def validate_how_long
    unless self.how_long.present?
      errors.add(:_,I18n.t("reviews.new.how_long"))
    end
  end
  def validate_what_for
    present=false
    I18n.t('what_for').each do |wf|
     present=true if self[wf["prop"]]==true
 		 end
    errors.add(:_,I18n.t("reviews.details.what_for")+"?") unless present
  end
  def validate_likes
    present=false
    [1,2,3].each do |i|
     present=true if self["like"+i.to_s].present?
 		 end
    errors.add(:_,I18n.t("reviews.new.select_like")) unless present
  end
  def validate_dislikes
    present=false
    [1,2,3].each do |i|
     present=true if self["dislike"+i.to_s].present?
 		 end
    errors.add(:_,I18n.t("reviews.new.select_dislike")) unless present
  end
  def validate_overall
    errors.add(:_,I18n.t("reviews.new.give_rate")) unless self.overall>0
  end


  def owned_or_drove?
    self.ownership_id=='3' or self.ownership_id=='4'
  end
  def other?
    self.how_well==5
  end
  def experience_length
    locales=I18n.available_locales.map {|l| l.to_s} 
    locales.each do |loc| 
      experience=self.send("experience_"+loc)
      if experience.present? 
    if experience.length<100
      errors.add(:experience,'is too short')
      return
    end
     if experience.length>2000
      errors.add(:experience,'is too long')
      return
    end
    end
  end
end
end
