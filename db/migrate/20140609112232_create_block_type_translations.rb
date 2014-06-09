class CreateBlockTypeTranslations < ActiveRecord::Migration

  def up
    Graphite::ElectiveBlock::BlockType.create_translation_table! name: :string
  end

  def down
    Graphite::ElectiveBlock::BlockType.drop_translation_table!
  end

end
