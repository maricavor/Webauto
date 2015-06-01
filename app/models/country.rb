class Country < ActiveRecord::Base
  attr_accessible :name
  translates :name
  has_many :regions
  has_many :states
  has_many :cities, :through=>:states
  has_many :vehicles
  has_many :users
end