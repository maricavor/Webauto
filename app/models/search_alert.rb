class SearchAlert < ActiveRecord::Base
  attr_accessible :advert_id, :search_id
  belongs_to :search
  belongs_to :advert

end
