class PhotosController < ApplicationController
  
  def index
     @photos = Photo.order('created_at')
   end

   def new
     @photo = Photo.new
     @photos = Photo.order('created_at')
   end

   def create
     @photo = Photo.create(params[:photo])
   end
   def destroy
     @photo = Photo.find(params[:id])
     @photo.destroy
     flash[:notice] = "The photo was destroyed."
     redirect_to new_photo_path
   end
 
  

end
