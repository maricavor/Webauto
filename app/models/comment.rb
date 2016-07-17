class Comment < ActiveRecord::Base
  acts_as_paranoid
  attr_accessible :text, :user_id, :vehicle_id,:parent_id,:deleted_at
  has_ancestry
  validates :text, :presence=> true
  belongs_to :user
  belongs_to :vehicle
  after_create :inform_watchers
  
  private
  def inform_watchers
    Resque.enqueue(CommentMailer, self.id)
  end

end