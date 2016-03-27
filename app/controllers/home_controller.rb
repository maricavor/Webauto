class HomeController < ApplicationController

  def terms
   @title=t("home.terms.title")
  end
  def privacy
    @title=t("home.privacy.title")
  end
  def about
    @title=t("home.about.title")
  end
 
  def popular
    @title="Webauto.ee"
    @popular_makes=Make.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
    @popular_models=Model.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
    @popular_bodytypes=Bodytype.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
  end
  def site_map
    @title=t("home.site_map.title")
  end
  def seller_safety
  end
  def create_ad
    @title=t("home.create_ad.title")
    if params[:id]
      @garage_item=GarageItem.find(params[:id])
      if @garage_item.advert
        respond_to do |format|
        format.html {
        redirect_to :back 
        flash[:alert]=t("home.create_ad.exists")
      }
      end
    end
    end
  end
end