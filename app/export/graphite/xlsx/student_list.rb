class Graphite::Xlsx::StudentList < Graphite::Xlsx::XlsxStub

  attr_reader :students

  def initialize(students)
    super()

    @students = Student
    .where(id: students.collect(&:id))
    .includes(:student_studies => [:studies => [:course => :translations,
          :study_type => :translations, :study_degree => :translations,
          :specialization => :translations]],
      :accepted_elective_enrollments => [:block => :translations,
        :elective_module => :translations, :elective_block =>
          [:elective_block_studies, :translations]]).load

  end

  protected

  def xlsx_content
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)

    header = [
      I18n.t(:label_personal_data_student),
      I18n.t(:label_index_number),
      I18n.t(:label_course_singular),
      I18n.t(:label_study_degree),
      I18n.t(:label_studies_type),
      I18n.t(:label_specialty_singular),
      I18n.t(:label_semester_number),
      I18n.t(:label_elective_block_block_name),
      I18n.t(:label_elective_block_or_block_name)
    ]
    sheet.add_row header, :style => styles[:header]

    students.each do |student|
      student.accepted_elective_enrollments.each do |enrollment|
        student_studies = student.student_studies.detect do |ss|
          enrollment.elective_block.elective_block_studies.any? do |ebs|
            ss.studies_id == ebs.studies_id
          end
        end
        if student_studies.present?
          row = [
            student.surname_name,
            student.index_number,
            student_studies.studies.course.name,
            student_studies.studies.study_degree.name,
            student_studies.studies.study_type.name,
            student_studies.studies.specialization.try(:name),
            student_studies.semester_number,
            enrollment.elective_block.name,
            enrollment.block_id.present? ? enrollment.block.try(:name) :
              enrollment.elective_module.try(:name)
          ]
          sheet.add_row row
        end
      end
    end
    sheet.add_table "A1:#{(64 + header.length).chr}#{students.length}",
      :name => I18n.t(:label_elective_block_report_student_list)
    sheet.column_widths 25, 12, 15, 15, 15, 20, 12, 25
  end

end
