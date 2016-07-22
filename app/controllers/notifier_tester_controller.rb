class NotifierTesterController < ApplicationController
  layout :false
  def comment_updated
    @comment = Comment.last
    @user= current_user
  end
  def vehicle_price_updated
    @vehicle = Vehicle.with_deleted.find(867)
    @user= current_user
  end
  def vehicle_status_sold
    @vehicle = Vehicle.with_deleted.find(867)
    @user= current_user
    @delete_reason_id=3
  end
  def send_to_friend_submitted
    @vehicle=Vehicle.with_deleted.find(867)
    @inquiry=Inquiry.new
    @inquiry.message="This is a message"
  end
  def index
    @actions=NotifierTesterController.action_methods
  end
end
