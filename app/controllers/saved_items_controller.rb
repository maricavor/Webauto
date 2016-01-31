class SavedItemsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :set_max_saves,:only=>[:remove_all,:index,:destroy]
  def destroy
    @saved_item = current_user.saved_items.find(params[:id])
    @saved_item.destroy
    @saved_items=current_user.saved_items
    @count=@saved_items.count
    respond_to do |format|
      format.html { redirect_to :back, :notice => t("saved_items.destroyed") }
      format.js {flash.now[:notice]= t("saved_items.destroyed") }
      format.json { head :no_content }
    end
  end
  def index
    @title= "Saved adverts - Webauto.ee"
    @saved_items=current_user.saved_items.where(:type_id=>@current_type).order("created_at desc")
    @count=@saved_items.count
  end
  def remove_all
    @count=0
    current_user.saved_items.destroy_all
    respond_to do |format|
      format.html {
        flash[:notice] = t("saved_items.remove_all")
        redirect_to saved_items_url
      }
      format.js { flash.now[:notice]= t("saved_items.remove_all") }
    end
  end
  private
  def set_max_saves
    @max_saves=10
  end
end