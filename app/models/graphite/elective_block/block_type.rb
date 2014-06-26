class Graphite::ElectiveBlock::BlockType < ActiveRecord::Base

  translates :name
  globalize_accessors :locales => I18n.available_locales

  has_many :elective_blocks

  validates :name, :const_name, presence: true


  def choose_n_from_m?
    const_name == 'elective_block_n_from_m_subjects'
  end

end
