class SavedItem < ActiveRecord::Base
  attr_accessible :user_id, :vehicle_id,:type_id
  belongs_to :user
  belongs_to :vehicle
  
  validates :vehicle_id, :uniqueness => { :scope => :user_id }
  validate :total_saves,:on=>:create
  after_save :watch
  after_destroy :unwatch

  def vehicle
    Vehicle.unscoped {super}
  end

  def saved_by_others?
  	SavedItem.exists?(['vehicle_id LIKE ? AND user_id <> ?', self.vehicle_id,self.user_id]) 
  end

  private
  def total_saves
    if self.user.saved_items.count>9
      errors[:base] << I18n.t("saved_items.total_saves")
      return
    end

  end
  def watch
    if self.vehicle
    watchers=self.vehicle.watchers
    usr=self.user
    watchers << usr unless watchers.include?(usr)
  end
  end
  def unwatch
   VehicleWatcher.where(user_id: self.user_id,vehicle_id: self.vehicle_id).delete_all
end
end