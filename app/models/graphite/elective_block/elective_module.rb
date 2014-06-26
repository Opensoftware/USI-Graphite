class Graphite::ElectiveBlock::ElectiveModule < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  belongs_to :elective_block
  belongs_to :employee, foreign_key: :owner_id
  has_many :enrollments, :class_name => "Graphite::ElectiveBlock::Enrollment"

  def <=>(other)
    name <=> other.name
  end

  def open_for_enrollments?
    student_amount > enrolled_students
  end
end
