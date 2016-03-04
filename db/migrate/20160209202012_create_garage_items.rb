class CreateGarageItems < ActiveRecord::Migration
  def change
    create_table :garage_items do |t|
      t.integer :user_id
      t.integer :vehicle_id
      t.integer :type_id
      t.timestamps
    end
  end
end
