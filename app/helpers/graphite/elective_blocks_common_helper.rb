module Graphite::ElectiveBlocksCommonHelper

  def elective_block_block_of_subjects_selection(elective_block)
    t "label_elective_block_type_#{elective_block.block_type.try(:const_name)}",
      counted_blocks: t('misc.block_count', count: elective_block.min_modules_amount.to_i),
      m: elective_block.elective_blocks.count
  end

  def elective_block_n_from_m_subjects_selection(elective_block)
    t "label_elective_block_type_#{elective_block.block_type.try(:const_name)}",
      counted_subjects: t('misc.subject_count', count: elective_block.min_modules_amount.to_i),
      m: elective_block.modules.count
  end

end
