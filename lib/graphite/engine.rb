require 'graphite/enrollment.rb'
require 'graphite/enrollment/elective_block_n_from_m_subject.rb'

module Graphite
  class Engine < ::Rails::Engine
    isolate_namespace Graphite

    initializer "graphite.assets.precompile" do |app|
      app.config.assets.precompile += %w(graphite/edit_elective_block.js graphite/elective_block.js
graphite/elective_block_list.js graphite/new_elective_block.js graphite/pipe.js
graphite/show_elective_block.js)
    end
  end
end