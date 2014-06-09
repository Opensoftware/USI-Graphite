class CreateSemesterNumbers < ActiveRecord::Migration
  def change
    create_table :graphite_elective_block_semester_numbers do |t|
	t.integer :number
	t.timestamps
    end
  end
end
