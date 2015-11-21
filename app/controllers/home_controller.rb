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
  end
end