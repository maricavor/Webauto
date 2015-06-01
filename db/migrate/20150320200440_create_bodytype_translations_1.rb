class CreateBodytypeTranslations1 < ActiveRecord::Migration
   def up
  	 Bodytype.create_translation_table!({
      name: :string
    }, {
      migrate_data: true
    })
  end

  def down
  	 Bodytype.drop_translation_table! migrate_data: true
  end
end
