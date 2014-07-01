require 'graphite/enrollment/processor'

class Graphite::Enrollment::ElectiveBlockBlockOfSubject < Graphite::Enrollment::Processor

  def initialize(elective_block, student)
    super(elective_block, student)

  end

  protected
  def partial
    'graphite/dashboard/elective_blocks'
  end
end
