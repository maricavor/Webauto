class Authentication < ActiveRecord::Base
  attr_accessible :provider,:uid
  belongs_to :user
  def provider_name
    if provider == 'google_oauth2'
      "Google"
    else
      provider.titleize
    end
  end
end
