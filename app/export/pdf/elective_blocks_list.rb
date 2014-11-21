class Pdf::ElectiveBlocksList < Pdf::PdfStub

  include Graphite::ElectiveBlocksCommonHelper

  attr_reader :elective_blocks

  def initialize(current_user, elective_blocks)
    super(:page_layout => :landscape)

    @elective_blocks = elective_blocks
  end

  protected

  def pdf_content

    t = []
    t_header = [
      I18n.t(:label_elective_block_name), I18n.t(:label_study_program),
      I18n.t(:label_annual), I18n.t(:label_semester),
      I18n.t(:label_type), I18n.t(:label_elective_block_plural)
    ]
    t << t_header
    elective_blocks.each do |elective_block|
      elective_block.annual_studies.each do |studies|
        t << [
          elective_block.name, studies.full_name,
          elective_block.annual.name, elective_block.semester.name,
          send("#{elective_block.block_type.const_name}_selection", elective_block),
          elective_block.modules.each_with_index
          .collect { |mod, i| "#{i+1}. #{mod.name} (#{I18n.t(:label_semester).downcase} #{mod.semester_number})" }.sort.join(",\n ")
        ]
      end
    end

    bold I18n.t(:label_elective_block_list), 10
    table(t, :width => bounds.width) do
      cells.style( :size => 9)
      row(0).background_color = "cdcdcd"

      columns(5).width = 260
      columns(2).width = 50
      columns(3).width = 50
    end
  end

  def pdf_title
    text I18n.t(:label_elective_block_list), :align => :left, :size => 10
  end
end
