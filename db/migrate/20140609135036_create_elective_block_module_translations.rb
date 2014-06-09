class CreateElectiveBlockModuleTranslations < ActiveRecord::Migration

  def up
    Graphite::ElectiveBlock::ElectiveModule.create_translation_table! name: :text
  end

  def down
    Graphite::ElectiveBlock::ElectiveModule.drop_translation_table!
  end

end
