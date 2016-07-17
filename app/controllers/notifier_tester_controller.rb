class NotifierTesterController < ApplicationController
  layout :false
  def comment_updated
    @comment = Comment.last
    @user= current_user
  end
  def vehicle_price_updated
    @vehicle = Vehicle.find(770)
    @user= current_user
  end
  def index
    @actions=NotifierTesterController.action_methods
  end
end
