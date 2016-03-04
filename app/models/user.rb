class User < ActiveRecord::Base
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name,:email, :primary_phone,:secondary_phone, :password, :password_confirmation, :remember_me,:tos_agreement,:company_name,:company_reg,:address1,:address2,:country_id,:city_id,:state_id,:postal_code,:phone1,:phone2,:company_kmkr,:webpage,:is_dealer,:price_alert,:sold_alert,:interest_alert,:auto_alerts,:feature_alerts,:locale,:provider,:uid,:encrypted_password
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,:recoverable, :rememberable, :trackable, :validatable,:omniauthable,  :omniauth_providers => [:google_oauth2,:facebook]
  # Setup accessible (or protected) attributes for your model
  has_many :searches
  has_many :comments
  has_many :saved_searches, :class_name => 'Search', :foreign_key => 'user_id', :conditions => ['name IS NOT NULL']
  has_many :vehicle_watchers, :dependent=>:destroy
  has_many :saved_items,:dependent=>:destroy
  has_many :garage_items,:dependent=>:destroy
  #has_many :jobs, :foreign_key => 'user_id', :class_name => "Task"
  has_many :vehicles
  has_many :adverts
  has_many :impressions
  has_many :authentications
  has_one :dealer_picture,:dependent=>:destroy
  belongs_to :city
  belongs_to :country
  belongs_to :state
  #scope :dealers, where("is_dealer = ?", true)
  validates :tos_agreement, acceptance: true,:on => :create
  validates :company_name, presence: true, :if => "is_dealer == true"
 
  def self.search(search_params)
    
  if search_params
    dealers=User.where("is_dealer = ?", true)
    dealers=dealers.where('company_name LIKE ?', "%#{search_params[:name]}%") if search_params[:name].present?
    if search_params[:location].present?
      location=search_params[:location]
    dealers=dealers.where(:country_id=>location)
  end
    if search_params[:region].present?
      regions=search_params[:region].split(',')
    dealers=dealers.joins(:state,:city).where("states.name IN (:states) OR cities.name IN (:cities)",:states=>regions,:cities=>regions) 
  end
  else
    dealers=User.where("is_dealer = ? AND country_id = ?", true,8)
  end
  dealers
end
def apply_omniauth(omniauth)
  self.email=omniauth['info']['email'] if email.blank?
  self.name=omniauth['info']['name'] if name.blank?
  authentications.build(:provider=>omniauth['provider'],:uid=>omniauth['uid'])
end
def password_required?
  (authentications.empty? || !encrypted_password.blank?) && super
end
  def self.find_for_facebook_oauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.email=auth.info.email
      user.name = auth.info.name
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at) unless auth.credentials.expires_at.nil?
      user.skip_confirmation!
      user.save(:validate => false)
    end
  end
  def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        #registered_user.update_attributes(provider:access_token.provider,uid: access_token.uid)
        return registered_user
      else
        user = User.create(name: data["name"],
          provider:access_token.provider,
          email: data["email"],
          uid: access_token.uid ,
          password: Devise.friendly_token[0,20],
        )
      end
   end
end
  def full_address
    address=""
    address+=self.address1.to_s if self.address1.present?
    address+='+'+self.address2.to_s if self.address2.present?
    address+='+'+self.city_name.to_s
    address+='+'+self.country_name.to_s
    address
  end
  def city_name
    self.city ? self.city.name : ""
  end
    def country_name
    self.country ? self.country.name : ""
  end
    def state_name
    self.state ? self.state.name : ""
  end
   def dealer_name
  if self.is_dealer?
      "#{self.id} #{self.company_name}".parameterize
  end
  end
  def total_stock(type_id)
   self.adverts.where(:activated=>true,:type_id=>type_id)
  end
end