class Serie < ActiveRecord::Base
  attr_accessible :name,:make_id
  has_many :models
  belongs_to :make
end
