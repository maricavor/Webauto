class AddAttributesToSavedItems < ActiveRecord::Migration
  def change
    add_column :saved_items, :name, :string
    add_column :saved_items, :price, :decimal,:precision => 8, :scale => 2
  end
end