class Graphite::ElectiveBlocksMailer < ActionMailer::Base

  default :from => "autoresponder.szs@agh.edu.pl"

  include Resque::Mailer

  layout 'graphite/default_mailer'


  def enrolled_to_blocks(student_id, enrollment_ids)
    @user = Student.where(id: student_id).first.user
    @enrollments = Graphite::ElectiveBlock::Enrollment.where(id: enrollment_ids)

    mail(:to => @user.email,
      :subject => "#{Settings.app_name} - #{I18n.t(:mail_subject_enrolled_to_blocks,
      elective_block_name: @enrollments.first.elective_block.try(:name))}")
  end

end
