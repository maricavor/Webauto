class PhotosController < ApplicationController
  
  def index
     @photos = Photo.order('created_at')
   end

   def new
     @photo = Photo.new
   end

   def create
     @photo = Photo.new(params[:photo])
     if @photo.save
       flash[:notice] = "The photo was added!"
       redirect_to photos_path
     else
       render 'new'
     end
   end
   def destroy
     @photo = Photo.find(params[:id])
     @photo.destroy
     flash[:notice] = "The photo was destroyed."
     redirect_to photos_path
   end

  

end
