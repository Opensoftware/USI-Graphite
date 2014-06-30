class CreateElectiveBlockBlockTranslations < ActiveRecord::Migration
  def up
    Graphite::ElectiveBlock::Block.create_translation_table! name: :string
  end

  def down
    Graphite::ElectiveBlock::Block.drop_translation_table!
  end
end
