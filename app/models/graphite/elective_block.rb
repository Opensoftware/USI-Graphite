class Graphite::ElectiveBlock < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  belongs_to :block_type
  has_many :modules, :class_name => "Graphite::ElectiveBlock::ElectiveModule",
    dependent: :destroy
  accepts_nested_attributes_for :modules, :reject_if => lambda { |mod|
    mod[:name].blank? || mod[:owner_id].blank?
  }
  has_many :semester_assignments, :class_name => "Graphite::ElectiveBlock::SemesterAssignment",
    dependent: :destroy
  has_many :semester_numbers, through: :semester_assignments
  has_many :elective_block_studies, :class_name => "Graphite::ElectiveBlockStudies",
    dependent: :destroy
  has_many :studies, through: :elective_block_studies
  has_many :elective_blocks, foreign_key: :elective_block_id
  has_many :enrollments, class_name: 'Graphite::ElectiveBlock::Enrollment'
  belongs_to :annual
  belongs_to :semester

  scope :persisted, -> { where(state: :persisted) }

  def <=>(other)
    name <=> other.name
  end

end
