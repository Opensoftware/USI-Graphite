class Graphite::Xlsx::StudentList < Graphite::Xlsx::XlsxStub

  attr_reader :students

  def initialize(students)
    super()

  end

  protected

  def xlsx_content
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)

    header = [
      I18n.t(:label_personal_data_student),
      I18n.t(:label_email),
      I18n.t(:label_index_number),
      I18n.t(:label_ects_points),
      I18n.t(:label_average_grade),
      I18n.t(:label_course_singular),
      I18n.t(:label_study_degree),
      I18n.t(:label_studies_type),
      I18n.t(:label_specialty_singular),
      I18n.t(:label_semester_number),
      I18n.t(:label_elective_block_block_name),
      I18n.t(:label_filter_semester_season),
      I18n.t(:label_elective_block_or_block_name)
    ]
    sheet.add_row header, :style => styles[:header]


    rows

    sheet.add_table "A1:#{(64 + header.length).chr}#{students.length+2}",
      :name => I18n.t(:label_elective_block_report_student_list)
    sheet.column_widths 25, 20, 12, 15, 15, 15, 15, 15, 20, 12, 25
  end

  def rows
  end

end
