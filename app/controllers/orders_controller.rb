class OrdersController < ApplicationController
  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders }
    end
  end
  def alerts
    @searches=current_user.searches.where("name IS NOT NULL").where(:alert_freq=>"Alert")
       #Rails.logger.info _searches.map {|s| s.name }.join(',')
     @searches.each do |s|
       #Rails.logger.info "Checking saved search "+s.name+" for user "+s.user.email
       #Rails.logger.info "Adverts: "+s.adverts
       _current_adverts=s.run("background").results.map {|v| v.advert_id }.join(',') 
       #Rails.logger.info "Found adverts: "+_current_adverts
        _new_adverts=_current_adverts.split(',')-s.adverts.split(',')
       #Rails.logger.info "New adverts: "+new_adverts.join(',')
       if _new_adverts.size>0
         s.update_attributes(:adverts=>_current_adverts,:new_adverts=>_new_adverts.join(','))
         #Notifier.adverts_created(_new_adverts, s).deliver
       end
  end
  end
  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
    @cart = Cart.find(params[:cart_id])
 if @cart.line_items.empty?
 redirect_to root_url, notice: "Your cart is empty"
 return
 end
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.json
  def create

respond_to do |format|
if @order.save

format.html { redirect_to store_url, notice:'Thank you for your order.' }
format.json { render json: @order, status: :created,location: @order }
else
format.html { render action: "new" }
format.json { render json: @order.errors,status: :unprocessable_entity }
end
end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(params[:order])
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :no_content }
    end
  end
end
