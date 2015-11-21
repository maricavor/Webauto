class Type < ActiveRecord::Base
  attr_accessible :name
  has_many :vehicles
  has_many :adverts
  has_many :bodytypes
  has_many :makes
end