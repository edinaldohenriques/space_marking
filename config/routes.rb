Rails.application.routes.draw do
  namespace :searches do
    resources :users, only: [:index]
  end
  root 'spaces#index'

  get 'static_pages/index'
  get 'static_pages/show'

  # devise_for :users

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  resources :spaces, only: [:index, :show, :new, :create, :edit, :update, :destroy] do 
    member do 
      post :toggle_status
    end
    member do
      get :reservation_history
    end
  end
  
  resources :reservations, only: [:new, :create, :edit, :update, :destroy]
end
