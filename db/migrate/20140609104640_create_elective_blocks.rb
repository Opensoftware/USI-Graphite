class CreateElectiveBlocks < ActiveRecord::Migration
  def up
    create_table :graphite_elective_blocks do |t|
      t.text :name
      t.integer :min_ects_amount
      t.integer :min_modules_amount
      t.string :state

      t.references :block_type, :annual, :elective_block, :semester
      t.timestamps
    end
    add_index :graphite_elective_blocks, [:annual_id], name: 'elective_blocks_by_annual'
    add_index :graphite_elective_blocks, [:block_type_id, :annual_id], name: 'elective_blocks_by_block_type_annual'
    add_index :graphite_elective_blocks, [:elective_block_id], name: 'elective_blocks_by_blocks'
  end
  def down
    drop_table :graphite_elective_blocks
  end
end
