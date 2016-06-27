class PhotosController < ApplicationController
  before_filter :authenticate_user!
  skip_before_filter :get_current_type,:get_compared_items
  def index
     @photos = Photo.order('created_at')
   end

   def new
     @photo = Photo.new
     @photos = Photo.order('created_at')
   end


   def create
     @photo = Photo.new(params[:photo])
     @vehicle=@photo.vehicle
     @photos=Photo.where(:vehicle_id=>@vehicle.id).order(:position)
     @count=@photos.count
     @max_pictures=7
  
     if @count<@max_pictures
     if @photo.save
       @count+=1
       flash.now[:notice] = t("pictures.added")
     else
       flash.now[:alert] = t("pictures.failure") + @photo.errors.full_messages.join(', ')
     end
     else
       flash.now[:alert] = t("pictures.cannot_have",:max=>@max_pictures)
     end
   end
   
   def fail_upload
     flash.now[:alert] = t("pictures.failed_to_upload",:file=>params[:file],:error=>params[:error])
   end
   
   def update
     @photo = Photo.find(params[:id])
     @vehicle=@photo.vehicle
     if @photo.update_attributes(params[:photo])
       flash.now[:notice] = t("pictures.updated")
      
     else
       flash.now[:alert] = t("pictures.failure") + @photo.errors.full_messages.join(', ')
     end
   end

   def destroy
     @photo = Photo.find(params[:id])
     @vehicle=@photo.vehicle
     @photo.destroy
     @photos=Photo.where(:vehicle_id=>@vehicle.id).order(:position)
     @max_pictures=7
     @count=@photos.count
 
  
      respond_to do |format|
       format.html { redirect_to :back, :notice => t("pictures.destroyed") }
       format.js {flash.now[:notice] = t("pictures.destroyed") }
       format.json { head :no_content }
     end
   end
  
 
  

end
