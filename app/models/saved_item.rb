class SavedItem < ActiveRecord::Base
  attr_accessible :user_id, :vehicle_id
  belongs_to :user
  belongs_to :vehicle
  validates :vehicle_id, :uniqueness => { :scope => :user_id }
  after_save :watch
  after_destroy :unwatch

  def vehicle
    Vehicle.unscoped {super}
  end

  def saved_by_others?
  	SavedItem.exists?(['vehicle_id LIKE ? AND user_id <> ?', self.vehicle_id,self.user_id]) 
  end

  private

  def watch
    watchers=self.vehicle.watchers
    usr=self.user
    watchers << usr unless watchers.include?(usr)
  end
  def unwatch
    watchers=self.vehicle.watchers
    usr=self.user
    watchers >> usr if watchers.include?(usr)
  end
end