class Graphite::ElectiveBlockStudies < ActiveRecord::Base

  belongs_to :studies
  belongs_to :elective_block, :class_name => "Graphite::ElectiveBlock"

end
