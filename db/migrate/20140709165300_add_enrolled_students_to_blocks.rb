class AddEnrolledStudentsToBlocks < ActiveRecord::Migration
  def change
    add_column :graphite_elective_block_blocks, :enrolled_students, :integer, :default => 0
  end
end
