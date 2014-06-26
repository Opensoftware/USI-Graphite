require 'graphite/enrollment.rb'
require 'graphite/enrollment/elective_block_n_from_m_subject.rb'

module Graphite
  class Engine < ::Rails::Engine
    isolate_namespace Graphite
  end
end
