class CreateElectiveBlockStudies < ActiveRecord::Migration
  def change
    create_table :graphite_elective_block_studies do |t|
      t.references :studies, :elective_block
      t.timestamps
    end
    add_index :graphite_elective_block_studies, [:studies_id, :elective_block_id],
      name: :elective_block_by_studies_studies_elective_block
  end
end
