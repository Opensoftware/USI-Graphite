class Xlsx::ElectiveBlocksList < Xlsx::XlsxStub

  include Graphite::ElectiveBlocksCommonHelper

  attr_reader :current_user, :elective_blocks

  def initialize(current_user, elective_blocks)
    super()

    @elective_blocks = elective_blocks
    @current_user = current_user

  end

  protected

  def xlsx_content
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)
    sheet.name = I18n.t(:label_export_elective_blocks_sheet_name)

    h = [
      I18n.t(:label_elective_block_name),
      *header,
      I18n.t(:label_elective_block_plural)
    ]
    sheet.add_row h, :style => styles[:header]
    elective_blocks.each do |elective_block|
      elective_block.annual_studies.each do |studies|

        sheet.add_row [
          elective_block.name,
          *row(elective_block, studies),
          elective_block.modules.each_with_index
          .collect { |mod, i| "#{i+1}. #{mod.name} (#{I18n.t(:label_semester).downcase} #{mod.semester_number})" }.sort.join(",\n ")
        ], :types => [:string]


      end
    end

    # sheet.add_table "A1:#{(64 + h.length).chr}#{elective_blocks.length}", :name => I18n.t(:label_elective_block_list)
    # sheet.column_widths 20, 20, 40, 20, 20, 15, 15, 20, 50

    @sheet = @axlsx.workbook.add_worksheet :page_margins => {
    :top => 0.5, :bottom => 0.5 }
    sheet.page_setup.set(:orientation => :landscape, :paper_size => 10)
    sheet.name = I18n.t(:label_export_elective_subjects_sheet_name)

    h = [
      I18n.t(:label_elective_block_singular),
      I18n.t(:label_semester_number),
      I18n.t(:label_elective_block_block_singular),
      I18n.t(:label_elective_block_name),
      *header
    ]
    row = sheet.add_row h, :style => styles[:header]
    elective_blocks.each do |elective_block|
      elective_block.annual_studies.each do |studies|
        elective_block.modules.each do |mod|

          row = sheet.add_row [
            mod.name,
            mod.semester_number,
            mod.blocks.collect {|b| b.name }.join(", "),
            elective_block.name,
            *row(elective_block, studies)
          ], :types => [:string]

        end
      end
    end
    sheet.add_table "A1:#{(64 + h.length).chr}#{row.index + 1}", :name => I18n.t(:label_elective_block_list)
    sheet.column_widths 20, 15, 20, 40, 20, 20, 15, 15, 20, 50
  end

  private

  def header
    [
      I18n.t(:label_course_singular),
      I18n.t(:label_specialty_singular),
      I18n.t(:label_study_degree),
      I18n.t(:label_studies_type),
      I18n.t(:label_annual),
      I18n.t(:label_semester),
      I18n.t(:label_type)
    ]
  end

  def row(elective_block, studies)
    [
      studies.course.name,
      studies.specialization.try(:name),
      studies.study_degree.name,
      studies.study_type.name,
      elective_block.annual.name,
      elective_block.semester.name,
      send("#{elective_block.block_type.const_name}_selection", elective_block)
    ]
  end


end
