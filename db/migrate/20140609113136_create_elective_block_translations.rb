class CreateElectiveBlockTranslations < ActiveRecord::Migration
  def up
    Graphite::ElectiveBlock.create_translation_table! name: :text
  end

  def down
    Graphite::ElectiveBlock.drop_translation_table!
  end
end
