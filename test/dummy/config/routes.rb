Rails.application.routes.draw do

  mount Graphite::Engine => "/graphite"
end
