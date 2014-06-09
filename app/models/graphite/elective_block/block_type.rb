class Graphite::ElectiveBlock::BlockType < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  has_many :elective_blocks

  validates :name, :const_name, presence: true

end
