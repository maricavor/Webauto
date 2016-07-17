class CreatePriceAlerts < ActiveRecord::Migration
  def change
    create_table :price_alerts do |t|
      t.integer :vehicle_id
      t.integer :user_id

      t.timestamps
    end
    add_index :price_alerts, :vehicle_id
    add_index :price_alerts, :user_id
  end
end
