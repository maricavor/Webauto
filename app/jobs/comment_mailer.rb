class CommentMailer
  @queue = :high
  def self.perform(comment_id)
    comment=Comment.find(comment_id)
    user=comment.user
    if user.interest_alert
   (comment.vehicle.watchers - [user]).each do |u|
      Notifier.comment_updated(comment,u).deliver
    end
    end
  end
end