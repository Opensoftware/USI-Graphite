class CreateBlockModules < ActiveRecord::Migration
  def change
    create_table :graphite_elective_block_block_modules do |t|
      t.timestamps
      t.references :elective_block, :elective_module
    end
    add_index :graphite_elective_block_block_modules, [:elective_block_id, :elective_module_id], name: 'block_modules_by_block_module'
  end
end
