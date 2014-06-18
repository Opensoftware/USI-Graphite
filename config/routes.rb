Graphite::Engine.routes.draw do

  resources :elective_blocks do
    collection do
      post :create_and_edit
    end

    resources :modules
  end

end
