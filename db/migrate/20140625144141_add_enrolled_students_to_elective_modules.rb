class AddEnrolledStudentsToElectiveModules < ActiveRecord::Migration
  def change
    add_column :graphite_elective_block_elective_modules, :enrolled_students, :integer, :default => 0
  end
end
