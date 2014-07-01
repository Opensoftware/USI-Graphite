class AddEnrollByAverageGradeToElectiveBlocks < ActiveRecord::Migration
  def change
    add_column :graphite_elective_blocks, :enroll_by_avg_grade, :boolean, default: false
  end
end
