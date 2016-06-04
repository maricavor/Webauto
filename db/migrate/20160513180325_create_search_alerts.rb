class CreateSearchAlerts < ActiveRecord::Migration
  def change
    create_table :search_alerts do |t|
      t.integer :search_id
      t.integer :user_id

      t.timestamps
    end
    add_index :search_alerts, :search_id
    add_index :search_alerts, :user_id
  end
  
end
