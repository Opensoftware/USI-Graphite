class CreateBlockTypes < ActiveRecord::Migration
  def change
    create_table :graphite_elective_block_block_types do |t|
	t.text :name
	t.string :const_name

	t.timestamps
    end
  end
end
