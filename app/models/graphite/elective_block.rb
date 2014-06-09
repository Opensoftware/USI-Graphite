class Graphite::ElectiveBlock < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  belongs_to :block_type

  

end
