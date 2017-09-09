class CommentMailer
  @queue = :high
  def self.perform(comment_id)
    ActiveRecord::Base.verify_active_connections!
    comment=Comment.find(comment_id)
    user=comment.user
    vehicle=comment.vehicle
   (vehicle.watchers - [user,vehicle.user]).each do |u|
 
     if u.interest_alert 
      Notifier.comment_updated(comment,u).deliver
  
  end
    end
  end
end