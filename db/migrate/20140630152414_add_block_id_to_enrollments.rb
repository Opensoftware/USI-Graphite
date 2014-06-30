class AddBlockIdToEnrollments < ActiveRecord::Migration
  def change
    add_column :graphite_elective_block_enrollments, :block_id, :integer
    add_index :graphite_elective_block_enrollments, [:student_id, :block_id], :name => 'block_enrollments_by_student_block'
  end
end
