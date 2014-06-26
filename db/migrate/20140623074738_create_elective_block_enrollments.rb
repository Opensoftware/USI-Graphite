class CreateElectiveBlockEnrollments < ActiveRecord::Migration
  def change
    create_table :graphite_elective_block_enrollments do |t|
      t.timestamps
      t.string :state, default: 'pending'

      t.references :elective_block, :student, :elective_module
    end

    add_index :graphite_elective_block_enrollments, [:elective_block_id, :student_id], name: "elective_block_enrollments_by_block_student"
    add_index :graphite_elective_block_enrollments, [:elective_block_id, :elective_module_id], name: "elective_block_enrollments_by_block_module"
  end
end
