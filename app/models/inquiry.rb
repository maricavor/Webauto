
class Inquiry
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :name,:email,:phone,:message,:content, :vehicle_id,:friend_email,:mode,:report_as
  validates :name,:presence => true
  validates :friend_email,:presence => true,:if => :send_to_friend?
  validates :email,:format => { :with => /\b[A-Z0-9._%a-z\-]+@(?:[A-Z0-9a-z\-]+\.)+[A-Za-z]{2,4}\z/ }

  validates :message,:length => { :minimum => 10, :maximum => 1000 },:unless => :send_to_friend?
  validates :content,:format => { :with => /^$/ }


  def deliver(obj)
    return false unless valid?
    if self.mode=="inquiry"
      Notifier.inquiry_submitted(self,obj).deliver
    elsif self.mode=="send_to_friend"
      Notifier.send_to_friend_submitted(self,obj).deliver
    elsif self.mode=="contact_user"
      Notifier.contact_user_submitted(self,obj).deliver
    else
      Notifier.report_submitted(self,obj).deliver
    end
    #true
  end

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  def persisted?
    false
  end

  def send_to_friend?
    self.mode == "send_to_friend"
  end

end