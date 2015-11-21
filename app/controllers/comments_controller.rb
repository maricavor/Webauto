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
    respond_to do |format|
    if @comment.save

      if @comment.parent_id.nil?
        
          format.html { redirect_to @vehicle, :notice => t("comments.comm_created") }
          format.js {
            flash.now[:notice] = t("comments.comm_created")
          }
       
      else
       
          format.js {
            render 'create_reply'
            flash.now[:notice] = t("comments.reply_created")
          }
        end

   
    else
     
        format.html { redirect_to @vehicle, :alert => t("comments.comm_not_created") }
        format.js {
          flash.now[:alert] = @comment.errors.full_messages.to_sentence
          render 'fail_create.js.erb'
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