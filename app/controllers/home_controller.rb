class HomeController < ApplicationController

  def terms

  end
  def privacy
  end
  def about
  end
  def contact
  end
  def popular
     @popular_makes=Make.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
    @popular_models=Model.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
    @popular_bodytypes=Bodytype.where("type_id = ? AND popularity <> ?",@current_type.id,0).order("popularity desc","name asc").limit(10)
  end
  def site_map
  end
  def seller_safety
  end
end