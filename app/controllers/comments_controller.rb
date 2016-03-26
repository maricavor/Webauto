class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_vehicle
  skip_before_filter :get_current_type,:get_compared_items

  def new
    @parent=params[:parent_id]
    @comment=@vehicle.comments.build(:parent_id=>@parent)
    @user=@vehicle.user
  end
  
  def create
    @comment=@vehicle.comments.build(params[:comment].merge(:user_id => current_user.id))
    @user=@vehicle.user
    
    if @comment.save
      if @comment.parent_id.nil?
        respond_to do |format|
          format.js {
            flash.now[:notice] = t("comments.comm_created")
          }
        end
      else
       respond_to do |format|
          format.js {
            flash.now[:notice] = t("comments.reply_created")
            render 'create_reply'
            
          }
        end
        end

   
    else
     respond_to do |format|
        
        format.js {
          flash.now[:error] = @comment.errors.full_messages.to_sentence
          render 'fail_create'
        }
      end
    end
    
  end
  def destroy
    @comment = @vehicle.comments.find(params[:id])
    @user=@vehicle.user
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @vehicle, :notice => t("comments.comm_deleted") }
      format.js {
        flash.now[:notice] = t("comments.comm_deleted")
      }
    end
  end
  private

  def find_vehicle
    @vehicle=Vehicle.find(params[:vehicle_id])
  end
end