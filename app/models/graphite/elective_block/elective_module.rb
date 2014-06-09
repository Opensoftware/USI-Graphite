class Graphite::ElectiveBlock::ElectiveModule < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  belongs_to :elective_block

end
