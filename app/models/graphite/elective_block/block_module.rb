class Graphite::ElectiveBlock::BlockModule < ActiveRecord::Base

  belongs_to :block, class_name: 'Graphite::ElectiveBlock::Block',
    foreign_key: :elective_block_id
  belongs_to :elective_module

end
