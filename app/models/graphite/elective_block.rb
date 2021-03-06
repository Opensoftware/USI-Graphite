class Graphite::ElectiveBlock < ActiveRecord::Base

  include ::Workflow

  workflow_column :state
  # Workflow is used only for elective blocks having blocks.
  workflow do
    state :default do
      event :schedule, :transitions_to => :scheduled
    end
    state :scheduled do
      event :complete, :transitions_to => :default
    end
  end

  translates :name
  globalize_accessors :locales => I18n.available_locales

  belongs_to :block_type
  has_many :modules, class_name: "Graphite::ElectiveBlock::ElectiveModule",
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
  has_many :annual_studies, -> { distinct },
    through: :elective_block_studies, source: :studies
  has_many :elective_blocks, class_name: 'Graphite::ElectiveBlock::Block',
    dependent: :destroy
  accepts_nested_attributes_for :elective_blocks, :reject_if => lambda { |elective_block|
    elective_block[:module_ids].blank? || elective_block[:name].blank?
  }, allow_destroy: true
  has_many :enrollments, class_name: 'Graphite::ElectiveBlock::Enrollment'
  accepts_nested_attributes_for :enrollments, :reject_if => lambda { |enrollment|
    reject = true
    if enrollment[:state] == 'queued'
      reject &&= enrollment[:priority].blank?
    else
      reject &&= enrollment[:enroll] == "0"
    end
    reject
  }, allow_destroy: true
  belongs_to :annual
  belongs_to :semester

  scope :persisted, -> { where(state: :persisted) }
  scope :for_semester, ->(semester) do
    select("DISTINCT #{Graphite::ElectiveBlock.table_name}.*")
    .joins(:modules)
    .where("#{Graphite::ElectiveBlock::ElectiveModule.table_name}.semester_number" => semester)
  end
  scope :for_student_semester, ->(semester) do
    select("DISTINCT #{Graphite::ElectiveBlock.table_name}.*")
    .joins(:modules)
    .group("#{Graphite::ElectiveBlock.table_name}.id")
    .having("MIN(#{Graphite::ElectiveBlock::ElectiveModule.table_name}.semester_number) IN (?)", semester)
  end
  scope :by_semester, ->(semester) { for_semester(semester) }
  scope :by_semester_season, ->(semester) { where(:semester_id => semester) }
  scope :by_studies, ->(studies) do
    joins(:studies)
    .where("#{Studies.table_name}.id" => studies)
  end
  scope :by_annual, ->(annual) { where(:annual_id => annual) }
  scope :by_block_type, ->(block_type) { where(:block_type_id => block_type) }
  scope :parents_only, -> { where("#{Graphite::ElectiveBlock.table_name}.elective_block_id IS NULL") }
  scope :for_student, ->(student) do
    joins(:elective_block_studies)
    .where("#{Graphite::ElectiveBlockStudies.table_name}.studies_id IN (?)",
           student.student_studies.collect(&:studies_id))
  end


  def <=>(other)
    name <=> other.name
  end

  def enrollments_pending?(student)
    @enrollments_pending = {} unless defined?(@enrollments_pending)
    return @enrollments_pending[student] if @enrollments_pending.has_key?(student)
    @enrollments_pending[student] = enrollments.select("1 AS ONE").pending
    .for_student(student)
    .present?
  end

  def student_any_accepted_enrollment?(student)
    enrollments.select("1 AS ONE")
    .for_student(student)
    .accepted
    .present?
  end

  def student_queued?(student)
    enrollments.select("1 AS ONE")
    .for_student(student)
    .queued
    .present?
  end

  def student_enrolled?(student)
    @student_enrolled = {} unless defined?(@student_enrolled)
    return @student_enrolled[student] if @student_enrolled.has_key?(student)
    @student_enrolled[student] = enrollments
    .for_student(student)
    .any?
  end

  def student_accepted?(student)
    student_accepted =
      enrollments.for_student(student).accepted.count == min_modules_amount
    unless enroll_by_average_grade?
      student_accepted &&= !enrollments_pending?(student)
    end
    student_accepted
  end

  def enroll_by_average_grade?
    enroll_by_avg_grade
  end

  def scheduling_needed?
    enroll_by_average_grade? && enrollments.not_versioned.queued.any? &&
      current_state == 'default'
  end

  def self.include_peripherals
    includes(:annual, :translations, :block_type => :translations,
             :modules => [:translations, :employee => :employee_title])
  end

end
