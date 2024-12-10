Rails.application.routes.draw do
  mount MissionControl::Jobs::Engine, at: "/jobs"

  root 'spaces#index'

  namespace :searches do
    resources :users, only: [:index]
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :spaces, only: [:index, :show, :new, :create, :edit, :update, :destroy] do 
    member do 
      post :toggle_occupied
      post :toggle_status_active
      post :toggle_status_disable
      get :reservation_history
    end

    collection do
      get :reservation_history_filter
    end
  end
  
  resources :reservations, only: [:new, :create, :edit, :update, :destroy] do 
    collection do
      get :pending_reservation
    end
    member do 
      get :justification_approve
      patch :approve

      get :justification_cancel
      patch :cancel
    end
  end
end
