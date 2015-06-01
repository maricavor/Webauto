class MakeModelField < ActiveRecord::Base

  attr_accessible :md,:mk,:search_id,:make_name,:model_name
  belongs_to :search
  after_create :update_popularity

  private

  def update_popularity
    make=Make.find_by_name_and_type_id(self.make_name,self.search.tp)
    if make
    make_pop=make.popularity
    make.update_attributes(:popularity=>make_pop+1)
    end
    if self.model_name.present?
      self.model_name.split(",").each do |model_name|
        model=Model.find_by_name_and_make_id(model_name,make.id)
        if model
        	model_pop=model.popularity
        	model.update_attributes(:popularity=>model_pop+1)
        end
      end
    end
  end
end