class Graphite::Reports::ElectiveBlocksController < GraphiteController


  def student_list
    authorize! :manage, :elective_blocks_reports

    respond_to do |format|
      format.xlsx do
        students = Student.enrolled_to_elective_blocks
        cache_key = fragment_cache_key_for(students)
        data = Rails.cache.fetch(cache_key) do
          file = Graphite::Xlsx::StudentList.new(students)
          data = file.to_xlsx
          Rails.cache.write(cache_key, data)
          data
        end
        send_data(data, :filename => "#{t(:label_elective_block_report_student_list)}.xlsx", :type => "application/xlsx", :disposition => "inline")
      end
    end
  end
end
