module Graphite::ElectiveBlocksHelper

  def studies_filter_content
    return @studies_filter if defined?(@studies_filter)
    @studies_filter = [[t(:label_all), nil]] | Studies
    .include_peripherals
    .load
    .sort.collect {|s| [[s.course.name, *("(#{s.specialty.name})" if s.specialty_id.present?),
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
    @can_enroll_for_subject[subject] &&= subject.open_for_enrollments?
  end

  def elective_enrollments_available?
    return @enrollments_available if defined?(@enrollments_available)
    now = Time.now
    @enrollments_available = current_semester.elective_enrollments_begin <= now && now <= current_semester.elective_enrollments_end
  end

  def elective_block_enrollments_info
    if @elective_block.student_enrolled?(current_user.verifable)
      return content_tag(:div, :class => "alert alert-success") do
        content_tag :p do
          t(elective_enrollments_available? ? :label_elective_block_enrollment_accepted_desc_open : :label_elective_block_enrollment_accepted_desc_close)
        end
      end
    end
    if !elective_enrollments_available?
      desc = t :label_elective_block_enrollment_unavailable, :from_day => l(current_semester.elective_enrollments_begin), :to_day => l(current_semester.elective_enrollments_end)
    elsif @elective_block.enrollments_pending?(current_user.student)
      desc = t :label_elective_block_enrollment_pending_desc
    elsif @elective_block.block_type.choose_n_from_m?
      if !@elective_block.student_enrolled?(current_user.student)
        desc = t :label_elective_block_enrollment_n_from_m_incomplete, :subjects => t('misc.subject_count', :count => @elective_block.min_modules_amount)
      end
    else
    end
    if defined?(desc) && desc.present?
      content_tag :div, :class => "alert alert-info" do
        content_tag :p do
          desc
        end
      end
    end
  end

end
