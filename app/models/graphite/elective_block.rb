class Graphite::ElectiveBlock < ActiveRecord::Base

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
  has_many :elective_blocks, class_name: 'Graphite::ElectiveBlock::Block',
    dependent: :destroy
  accepts_nested_attributes_for :elective_blocks, :reject_if => lambda { |elective_block|
    elective_block[:module_ids].blank?
  }, allow_destroy: true
  has_many :enrollments, class_name: 'Graphite::ElectiveBlock::Enrollment'
  accepts_nested_attributes_for :enrollments, :reject_if => lambda { |enrollment|
    enrollment[:enroll] == "0"
  }, allow_destroy: true
  belongs_to :annual
  belongs_to :semester

  scope :persisted, -> { where(state: :persisted) }
  scope :for_semester, ->(semester) do
    select("DISTINCT #{Graphite::ElectiveBlock.table_name}.*")
    .joins(:modules)
    .where("#{Graphite::ElectiveBlock::ElectiveModule.table_name}.semester_number" => semester)
  end
  scope :by_semester, ->(semester) { for_semester(semester) }
  scope :by_studies, ->(studies) do
    joins(:studies)
    .where("#{Studies.table_name}.id" => studies)
  end
  scope :by_annual, ->(annual) { where(:annual_id => annual) }


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

  def student_enrolled?(student)
    @student_enrolled = {} unless defined?(@student_enrolled)
    return @student_enrolled[student] if @student_enrolled.has_key?(student)
    @student_enrolled[student] = false
    if block_type.choose_n_from_m?
      if min_modules_amount.present?
        @student_enrolled[student] = !enrollments_pending?(student) &&
          enrollments.for_student(student).count == min_modules_amount
      end
    end
    @student_enrolled[student]
  end

  def self.include_peripherals
    includes(:translations, :block_type => :translations,
      :modules => [:translations, :employee => :employee_title])
  end

end
