class CreateSemesterAssignments < ActiveRecord::Migration
  def change
    create_table :graphite_elective_block_semester_assignments do |t|
	t.references :elective_block, :semester_number
	t.timestamps
    end
    add_index :graphite_elective_block_semester_assignments, 
	    [:elective_block_id, :semester_number_id], 
	    name: 'semester_assignments_by_elective_block_semester_number'
  end
end
