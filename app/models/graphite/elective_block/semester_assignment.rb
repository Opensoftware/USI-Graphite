class Graphite::ElectiveBlock::SemesterAssignment < ActiveRecord::Base

  belongs_to :elective_block, :class_name => "Graphite::ElectiveBlock"
  belongs_to :semester_number, :class_name => "Graphite::ElectiveBlock::SemesterNumber"

end
