class Graphite::ElectiveBlock::ElectiveModule < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  belongs_to :elective_block
  belongs_to :employee, foreign_key: :owner_id
  has_many :enrollments, :class_name => "Graphite::ElectiveBlock::Enrollment"
  has_many :block_modules, class_name: "Graphite::ElectiveBlock::BlockModule",
    dependent: :destroy
  has_many :blocks, through: :block_module_associations,
    class_name: "Graphite::ElectiveBlock::Block", source: :elective_block

  def <=>(other)
    name <=> other.name
  end

  def open_for_enrollments?
    student_amount.blank? ||
      student_amount.to_i > enrolled_students.to_i
  end
end
