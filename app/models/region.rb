class Region < ActiveRecord::Base
  attr_accessible :name
  belongs_to :country
  has_many :vehicles
end