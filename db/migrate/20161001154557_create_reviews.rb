class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.integer :vehicle_id
      t.integer :how_well
      t.integer :how_long
      t.integer :performance
      t.integer :practicality
      t.integer :reliability
      t.integer :running_costs
      t.integer :satisfaction
      t.integer :what_for
      t.text :title
      t.text :experience
      t.boolean :declaration
      t.integer :like1
      t.integer :like2
      t.integer :like3
      t.integer :dislike1
      t.integer :dislike2
      t.integer :dislike3
      t.string :first_name
      t.integer :user_id
      t.timestamps
    end
  end
end
