class CreateDealerPictures < ActiveRecord::Migration
  def change
    create_table :dealer_pictures do |t|
      t.integer :user_id
      t.string :name
      t.string :file
      t.string :remote_file_url

      t.timestamps
    end
  end
end
