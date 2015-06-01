class Model < ActiveRecord::Base
  attr_accessible :make_id, :name,:model_id,:popularity,:type_id
  belongs_to :make
  belongs_to :serie
  has_many :vehicles
 
  def custom_name
  	if self.has_series?
  		serie_name=Serie.find(self.serie_id).name
  		return '['+serie_name+'] '+self.name
  	else
      return '[undefined] '+self.name
    end
  end
  def has_series?
    self.serie_id!=nil
  end
  def type_id
    self.make.type_id
  end
end
