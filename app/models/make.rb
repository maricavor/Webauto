class Make < ActiveRecord::Base
  attr_accessible :name,:popularity,:type_id
  has_many :vehicles
  has_many :models
  has_many :series
  belongs_to :type
  def custom_models
    self.models
  end
end