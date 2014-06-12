class Graphite::ElectiveBlock < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  belongs_to :block_type
  has_many :modules, :class_name => "Graphite::ElectiveBlock::ElectiveModule",
    dependent: :destroy
  has_many :semester_assignments, :class_name => "Graphite::ElectiveBlock::SemesterAssignment",
    dependent: :destroy
  has_many :semester_numbers, through: :semester_assignments
  has_many :elective_block_studies, :class_name => "Graphite::ElectiveBlockStudies",
    dependent: :destroy
  has_many :studies, through: :elective_block_studies


end
