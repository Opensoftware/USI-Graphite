class AddVersionToEnrollments < ActiveRecord::Migration
  def change
    add_column :graphite_elective_block_enrollments, :version, :bigint
  end
end
