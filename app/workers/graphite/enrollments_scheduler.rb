class Graphite::EnrollmentsScheduler
  @queue = :graphite_enrollments

  def self.perform(elective_block_id)

    worker = Inner.new(elective_block_id)
    worker.perform
  end

  protected

  class Inner
    attr_reader :elective_block, :blocks_enrollments

    def initialize(elective_block_id)
      @elective_block = Graphite::ElectiveBlock
      .includes(:elective_blocks => [:modules, :enrollments => [:student]])
      .find(elective_block_id)
    end

    def perform

      # Make a backup of enrollments, in case of enrollments scheduling ended
      # with incorrect result
      Graphite::ElectiveBlock::Enrollment.transaction do
        begin
          backup = []
          version = Time.zone.now.to_i
          Graphite::ElectiveBlock::Enrollment
          .for_block(elective_block.elective_blocks)
          .queued.each do |enrollment|
            backup << Graphite::ElectiveBlock::Enrollment.new(state: 'archived',
              elective_block_id: enrollment.elective_block_id,
              student_id: enrollment.student_id,
              block_id: enrollment.block_id, priority: enrollment.priority,
              version: version)
          end
          backup.each(&:save!)
        rescue ActiveRecord::RecordInvalid
          @backup_failed = true
          raise ActiveRecord::Rollback
        end
      end

      unless @backup_failed
        Graphite::ElectiveBlock::Enrollment.transaction do
          student_ids = Student
          .elective_blocks(elective_block.elective_blocks)
          .queued_blocks
          .pluck("#{Student.table_name}.id")

          # Fetch students and sort them by their ECTS amount and average grade
          students = Student.includes(:elective_enrollments => :block)
          .where(id: student_ids)
          .sort_by {|student| [student.passed_ects.to_i,
              student.average_grade.to_f] }.reverse
          puts students.collect {|s| "#{s.surname_name}"}.join("\n")

          block_enrollments = {}
          elective_block.elective_blocks.each_with_index do |block|
            block_enrollments[block.id] = block.enrolled_students.to_i
          end

          students.each do |student|
            enrollments = student.elective_enrollments
            .for_elective_block(elective_block)
            .sort {|e1, e2| e1.priority.to_i <=> e2.priority.to_i }
            while(enrollment = enrollments.shift)
              # Check if student may still enroll to block
              if !elective_block.student_accepted?(enrollment.student)
                # Student can enroll, however given block may be full. If so,
                # reject student enrollment
                if block_enrollments[enrollment.block_id] < enrollment.block.student_amount &&
                    enrollment.can_accept?
                  enrollment.accept!
                  block_enrollments[enrollment.block_id] += 1
                elsif enrollment.queued?
                  enrollment.reject! if enrollment.can_reject?
                end
              else
                # Drop all lower priority enrollments if given student already
                # enrolled to enough amount of blocks
                enrollment.destroy
              end
            end
          end
        end
      end
    end

  end
end
