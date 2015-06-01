class Order < ActiveRecord::Base
  attr_accessible :pay_type, :advert_id
  belongs_to :advert
  PAYMENT_TYPES = [ "Check", "Credit card", "Purchase order" ]
  #validates :pay_type, inclusion: PAYMENT_TYPES
  has_many :line_items, dependent: :destroy
   def total_price
line_items.to_a.sum { |item| item.price }
end
  def add_line_items_from_cart(cart)
cart.line_items.each do |item|
item.cart_id = nil
line_items << item
end
end
end
