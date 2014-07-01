class AddPrioritiesToEnrollments < ActiveRecord::Migration
  def change
    add_column :graphite_elective_block_enrollments, :priority, :integer
  end
end
