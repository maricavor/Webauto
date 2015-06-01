class CreateVehicleTranslations < ActiveRecord::Migration
  def up
  	  Vehicle.create_translation_table!({
      description: :text
    },{migrate_data: true})
  end

  def down
  	Vehicle.drop_translation_table! migrate_data: true
  end
end
