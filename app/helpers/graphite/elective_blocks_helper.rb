module Graphite::ElectiveBlocksHelper

  include Graphite::ElectiveBlocksCommonHelper

  def block_type_filter_content
    return @block_type_filter if defined?(@block_type_filter)
    @block_type_filter = [[t(:label_all), nil]] | Graphite::ElectiveBlock::BlockType.all
    .collect {|bt| ["#{bt.name} (#{t("label_elective_block_type_#{bt.const_name}_letter")})", bt.id]}
  end

  def studies_filter_content
    return @studies_filter if defined?(@studies_filter)
    @studies_filter = [[t(:label_all), nil]] | Studies
    .include_peripherals
    .load
    .sort.collect {|s| [[s.course.name, *("(#{s.specialization.name})" if s.specialty_id.present?),
          " - #{s.study_type.name.downcase} #{s.study_degree.name.camelize(:lower)}"].join(" "),
        s.id]}
  end

  def semester_filter_content
    return @semester_filter if defined?(@semester_filter)
    @semester_filter = [[t(:label_all), nil]] | (1..8).collect {|i| [i, i]}
  end

  def elective_can_enroll?
    return @elective_can_enroll if defined?(@elective_can_enroll)
    @elective_can_enroll = elective_enrollments_available?
    @elective_can_enroll &&= !@elective_block.enrollments_pending?(current_user.student)
  end

  def can_enroll_for_subject?(subject)
    @can_enroll_for_subject = {} unless defined?(@can_enroll_for_subject)
    return @can_enroll_for_subject[subject] if @can_enroll_for_subject.has_key?(subject)
    @can_enroll_for_subject[subject] = elective_can_enroll?
    unless current_user.student.elective_enrollments.for_subject(subject).any?
      @can_enroll_for_subject[subject] &&= subject.open_for_enrollments?
    end
    @can_enroll_for_subject[subject]
  end

  def elective_enrollments_available?
    return @enrollments_available if defined?(@enrollments_available)
    now = Time.now
    @enrollments_available = current_semester.elective_enrollments_begin <= now && now <= current_semester.elective_enrollments_end
  end

  def elective_block_enrollments_info
    if @elective_block.student_accepted?(current_user.verifable)
      content = alert(:success) do
        t(elective_enrollments_available? ? :label_elective_block_enrollment_accepted_desc_open : :label_elective_block_enrollment_accepted_desc_close)
      end
      return content
    elsif @elective_block.student_enrolled?(current_user.verifable)
      if @elective_block.enroll_by_average_grade?
        if current_user.verifable.has_queued_enrollments_for_module?(@elective_block)
          content = alert(:success) do
            t(elective_enrollments_available? ? :label_elective_block_enrollment_queued_desc_open : :label_elective_block_enrollment_accepted_desc_close)
          end
        end
      else
        content = alert(:info) do
          t(:label_elective_block_enrollment_pending_desc)
        end
      end
      return content
    end
    if !elective_enrollments_available?
      desc = t :label_elective_block_enrollment_unavailable, :from_day => l(current_semester.elective_enrollments_begin), :to_day => l(current_semester.elective_enrollments_end)
    elsif @elective_block.enrollments_pending?(current_user.student)
      desc = t :label_elective_block_enrollment_pending_desc
    elsif @elective_block.block_type.choose_n_from_m?
      if !@elective_block.student_accepted?(current_user.student)
        desc = t :label_elective_block_enrollment_n_from_m_incomplete, :subjects => t('misc.subject_count', :count => @elective_block.min_modules_amount)
      end
    elsif @elective_block.block_type.block_of_subjects?
      if @elective_block.enroll_by_average_grade?
        desc = t :label_elective_block_block_of_subjects_avg_grade_incomplete, :blocks => t('misc.block_count', :count => @elective_block.min_modules_amount)
      else
        desc = t :label_elective_block_block_of_subjects_incomplete, :blocks => t('misc.block_count', :count => @elective_block.min_modules_amount)
      end
    else
    end
    if defined?(desc) && desc.present?
      alert(:info) do
        raw desc
      end
    end
  end

  private

  def alert(type)
    content_tag :div, :class => "alert alert-#{type}" do
      content_tag :p do
        yield
      end
    end
  end
end
