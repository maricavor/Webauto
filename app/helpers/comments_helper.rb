module CommentsHelper
  def nested_comments(comments)
    comments.map do |comment,sub_comments|
      render(comment) + nested_comments(sub_comments)
    end.join.html_safe
  end
end