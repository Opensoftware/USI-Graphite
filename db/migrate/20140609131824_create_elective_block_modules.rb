class CreateElectiveBlockModules < ActiveRecord::Migration
  def change
    create_table :graphite_elective_block_elective_modules do |t|
      t.text :name
      t.text :www
      t.integer :student_amount
      t.integer :ects_amount
      t.integer :semester_number
      t.references :elective_block, :owner

      t.timestamps
    end
  end
end
