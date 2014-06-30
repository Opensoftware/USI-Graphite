class Graphite::ElectiveBlock::BlockType < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  has_many :elective_blocks

  validates :name, :const_name, presence: true

  def self.block_of_subjects
    where(const_name: 'elective_block_block_of_subjects').first
  end

  def choose_n_from_m?
    const_name == 'elective_block_n_from_m_subjects'
  end

  def block_of_subjects?
    const_name == 'elective_block_block_of_subjects'
  end

end
