class CreateAdverts < ActiveRecord::Migration
  def change
    create_table :adverts do |t|
      t.integer :uid
      t.integer :vehicle_id
      t.decimal :price,:precision => 8, :scale => 2
      t.string :type
      t.string :contact_number
      t.string :secondary_number
      t.string :email
      t.integer :popularity,:default => 0
      t.boolean :is_active,:default => false
      t.timestamps
    end
    add_index :adverts, :vehicle_id, :unique => true
  end
end
