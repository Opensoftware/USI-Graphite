require 'active_support/concern'

module Graphite::Enrollment::StatusInfo
  extend ActiveSupport::Concern

  include ActionView::Helpers::TagHelper

  attr_accessor :output_buffer

  def elective_block_enrollment_status(student, elective_mod)
    if elective_mod.student_accepted?(student)
      content_tag :span, :class => "text-success" do
        I18n.t(:label_elective_block_enrollment_accepted)
      end
    elsif elective_mod.student_queued?(student)
      content_tag :span, :class => "text-success" do
        I18n.t(:label_elective_block_enrollment_queued)
      end
    elsif student.has_pending_enrollments_for_module?(elective_mod)
      content_tag :span do
        I18n.t(:label_elective_block_enrollment_pending)
      end
    elsif elective_mod.student_any_accepted_enrollment?(student)
      content_tag :span, :class => "text-danger" do
        I18n.t(:label_elective_block_enrollment_partial_accepted)
      end
    else
      content_tag :span, :class => "text-danger" do
        I18n.t(:label_elective_block_student_enroll)
      end
    end
  end

end
