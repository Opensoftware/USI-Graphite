Graphite::Engine.routes.draw do

  resources :elective_blocks do
    resources :blocks, controller: "elective_block/blocks"
    collection do
      post :create_and_edit
      get :event_pipe
      delete :collection_destroy
    end
    member do
      patch :enroll
      patch :perform_scheduling
    end

    resources :modules
  end

end
