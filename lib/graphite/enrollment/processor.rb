require 'graphite/enrollment/status_info'

class Graphite::Enrollment::Processor

  attr_reader :elective_block, :student
  attr_reader :student_enrollments, :pending_enrollments, :accepted_enrollments

  include Graphite::Enrollment::StatusInfo

  def initialize(elective_block, student)
    @elective_block = elective_block
    @student = student
  end

  def perform
    preprocess
    process
    after_process
    postprocess
  end

  protected

  def after_process
  end

  def partial
    ''
  end

  def preprocess
    @student_enrollments = Graphite::ElectiveBlock::Enrollment
    .for_student(student)
    .for_elective_block(elective_block)
    .order("updated_at DESC")
    @pending_enrollments = student_enrollments.select do |enrollment|
      enrollment.pending?
    end
    @accepted_enrollments = student_enrollments.select do |enrollment|
      enrollment.accepted?
    end
  end

  def process
    if elective_block.min_modules_amount.present?
      pending_enrollments.shift(elective_block.min_modules_amount -
          accepted_enrollments.length).each(&:accept!)
      Graphite::ElectiveBlock::Enrollment
      .where(:id => pending_enrollments).destroy_all
      student_enrollments.reload
    end
  end

  def postprocess
    if student_enrollments.any?
      begin
        redis = Redis.new
        enrollments = Graphite::ElectiveBlock::Enrollment
        .for_student(student)
        .for_elective_block(elective_block)
        renderer = ActionView::Base.new(Graphite::Engine.paths['app/views'].first)

        redis.publish("graphite.enrollments.student_id.#{student.id}",
          {:elective_block_id => elective_block.id,
            :message => elective_block_enrollment_status(student, elective_block),
            :subjects => renderer.render(:partial => partial,
              :locals => {:elective_block => elective_block,
                :student => student,
                :enrollments => enrollments})}.to_json)
      ensure
        redis.quit
      end
    end
  end
end
