class SearchAlert < ActiveRecord::Base
  attr_accessible :search_id, :user_id,:results
  belongs_to :user
  belongs_to :search
  
  def to_param
      "#{self.id} #{self.search.name}".parameterize
  end
end
