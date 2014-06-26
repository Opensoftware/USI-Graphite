class Graphite::EnrollmentsDequeue
  @queue = :graphite_enrollments

  def self.perform(elective_block_id, user_id)
    elective_block = Graphite::ElectiveBlock.find(elective_block_id)
    student = User.find(user_id).student

    processor = Graphite::Enrollment.const_get(elective_block.block_type.const_name.classify)
    .new(elective_block, student)
    processor.process

  end

end
