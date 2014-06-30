class Graphite::ElectiveBlock::Block < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  belongs_to :elective_block
  has_many :block_modules, class_name: "Graphite::ElectiveBlock::BlockModule",
    dependent: :destroy, foreign_key: :elective_block_id
  has_many :modules, through: :block_modules,
    class_name: "Graphite::ElectiveBlock::ElectiveModule", source: :elective_module
  has_many :enrollments, class_name: "Graphite::ElectiveBlock::Enrollment",
    dependent: :destroy

end
