class HomeController < ApplicationController

  def terms
   @title="Terms & Conditions - Webauto.ee"
  end
  def privacy
    @title="Privacy Policy - Webauto.ee"
  end
  def about
    @title="About Us - Webauto.ee"
  end
 
  def popular
    @title="webauto.ee"
    @popular_makes=Make.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
    @popular_models=Model.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
    @popular_bodytypes=Bodytype.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
  end
  def site_map
    @title="Sitemap - Webauto.ee"
  end
  def seller_safety
    @title="webauto.ee"
  end
  def create_ad
    @title="Sell My Car - Webauto.ee"
    if params[:id]
      @garage_item=GarageItem.find(params[:id])
      if @garage_item.advert
        respond_to do |format|
        format.html {
        redirect_to :back 
        flash[:alert]="Advert already exists"
      }
      end
    end
    end
  end
end