class Serie < ActiveRecord::Base
  attr_accessible :name
  has_many :models
  belongs_to :make
end
