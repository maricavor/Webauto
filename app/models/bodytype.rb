class Bodytype < ActiveRecord::Base
  attr_accessible :name,:popularity,:as => [:admin, :default]
  translates :name
  has_many :vehicles
  belongs_to :type
end