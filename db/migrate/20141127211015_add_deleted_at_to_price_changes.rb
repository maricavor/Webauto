class AddDeletedAtToPriceChanges < ActiveRecord::Migration
  def change
    add_column :price_changes, :deleted_at, :datetime
    add_index :price_changes, :deleted_at
  end
end
