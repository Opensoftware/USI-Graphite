require 'graphite/enrollment/status_info'

class Graphite::Enrollment::ElectiveBlockNFromMSubject

  attr_reader :elective_block, :student

  include Graphite::Enrollment::StatusInfo

  def initialize(elective_block, student)
    @elective_block = elective_block
    @student = student
  end

  def process
    student_enrollments = Graphite::ElectiveBlock::Enrollment
    .for_student(student)
    .for_elective_block(elective_block)
    .order("updated_at DESC")
    pending_enrollments = student_enrollments.select do |enrollment|
      enrollment.pending?
    end
    accepted_enrollments = student_enrollments.select do |enrollment|
      enrollment.accepted?
    end
    if elective_block.min_ects_amount.present? && elective_block.min_modules_amount.present?

    elsif elective_block.min_modules_amount.present?
      pending_enrollments.shift(elective_block.min_modules_amount -
          accepted_enrollments.length).each(&:accept!)
      Graphite::ElectiveBlock::Enrollment
      .where(:id => pending_enrollments).destroy_all
    elsif elective_block.min_ects_amount.present?

    end

    if student_enrollments.any?
      begin
        redis = Redis.new
        elective_module_enrollments = Graphite::ElectiveBlock::Enrollment
        .for_student(student)
        .for_elective_block(elective_block)
        renderer = ActionView::Base.new(Graphite::Engine.paths['app/views'].first)

        redis.publish("graphite.enrollments.student_id.#{student.id}",
          {:elective_block_id => elective_block.id,
            :message => elective_block_enrollment_status(student, elective_block),
            :subjects => renderer.render(:partial => 'graphite/dashboard/elective_subjects',
              :locals => {:elective_block => elective_block,
                :student => student,
                :elective_module_enrollments => elective_module_enrollments})}.to_json)
      ensure
        redis.quit
      end
    end
  end
end
