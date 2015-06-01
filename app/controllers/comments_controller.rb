class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :find_vehicle
  skip_before_filter :get_current_type


  def new
    @parent=params[:parent_id]
    @comment=@vehicle.comments.build(:parent_id=>@parent)
  end
  def create
    @comment=@vehicle.comments.build(params[:comment].merge(:user_id => current_user.id))
    if @comment.save
      if @comment.parent_id.nil?
        respond_to do |format|
          format.html { redirect_to @vehicle, :notice => "Comment has been created." }
          format.js {
            flash.now[:notice] = 'Comment has been created.'
          }
        end
      else
        respond_to do |format|
          format.js {
            render 'create_reply'
            flash.now[:notice] = 'Reply has been created.'
          }
        end

      end
    else
      respond_to do |format|
        format.html { redirect_to @vehicle, :alert => "Comment has not been created." }
        format.js {
          flash.now[:alert] = @comment.errors.full_messages.to_sentence
          render 'fail_create.js.erb'
        }
      end
    end
  end
  def destroy
    @comment = @vehicle.comments.find(params[:id])
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to @vehicle, :notice => 'Comment deleted' }
      format.js {
        flash.now[:notice] = 'Comment has been deleted.'
      }
    end
  end
  private

  def find_vehicle
    @vehicle=Vehicle.find(params[:vehicle_id])
  end
end