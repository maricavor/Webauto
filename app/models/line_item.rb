class LineItem < ActiveRecord::Base
  attr_accessible :order_id, :service_id
  belongs_to :service
  belongs_to :order
  def price
  service.price 
 end
  end
