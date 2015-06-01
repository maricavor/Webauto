atom_feed do |feed|
feed.title "Who bought #{@service.title}"
latest_order = @service.orders.sort_by(&:updated_at).last
feed.updated( latest_order && latest_order.updated_at )
@service.orders.each do |order|
feed.entry(order) do |entry|
entry.title "Order #{order.id}"
entry.summary type: 'xhtml' do |xhtml|

xhtml.table do
xhtml.tr do
xhtml.th 'Service'
xhtml.th 'Price'
end
order.line_items.each do |item|
xhtml.tr do
xhtml.td item.service.title
xhtml.td number_to_currency item.price
end
end
xhtml.tr do
xhtml.th 'total', colspan: 2
xhtml.th number_to_currency \
order.line_items.map(&:price).sum
end
end
xhtml.p "Paid by #{order.pay_type}"
end

end
end
end