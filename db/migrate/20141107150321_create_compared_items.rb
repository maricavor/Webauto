class CreateComparedItems < ActiveRecord::Migration
  def change
    create_table :compared_items do |t|
      t.integer :vehicle_id
      t.integer :user_id
      t.string :ip_address
      t.string :session_hash
      t.timestamps
    end
    add_index :compared_items, :vehicle_id
  end
end
