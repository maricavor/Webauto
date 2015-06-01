class SavedItemsController < ApplicationController
  before_filter :authenticate_user!
  def destroy
    @saved_item = current_user.saved_items.find(params[:id])
    @saved_item.destroy
    @saved_items=current_user.saved_items
    @max_saves=10
    respond_to do |format|
      format.html { redirect_to :back, :notice => "Successfully deleted item." }
      format.js
      format.json { head :no_content }
    end
  end
  def index
    @saved_items=current_user.saved_items.order("created_at desc")
    @max_saves=10
  end
  def remove_all
    current_user.saved_items.destroy_all
    flash[:notice] = "You have removed all items!"
    redirect_to saved_items_url

  end

end