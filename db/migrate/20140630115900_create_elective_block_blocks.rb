class CreateElectiveBlockBlocks < ActiveRecord::Migration
  def change
    create_table :graphite_elective_block_blocks do |t|
      t.timestamps
      t.string :name
      t.integer :student_amount
      t.references :elective_block
    end
  end
end
