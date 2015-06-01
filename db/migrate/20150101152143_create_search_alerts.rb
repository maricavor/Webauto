class CreateSearchAlerts < ActiveRecord::Migration
  def change
    create_table :search_alerts do |t|
      t.integer :search_id
      t.integer :advert_id
      t.timestamps
    end
  end
end
