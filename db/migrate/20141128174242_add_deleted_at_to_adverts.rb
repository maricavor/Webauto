class AddDeletedAtToAdverts < ActiveRecord::Migration
  def change
    add_column :adverts, :deleted_at, :datetime
    add_index :adverts, :deleted_at
  end
end
