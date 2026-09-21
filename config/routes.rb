Rails.application.routes.draw do
  root "portals#index"

  resource :session, only: %i[ new create destroy ]
  resources :portals, only: %i[ index show ] do
    resources :bookings, only: :create
  end
  resources :bookings, only: %i[ index destroy ]
  resource :profile, only: %i[ show update ] do
    patch :password
  end

  namespace :admin do
    resources :portals, except: :show do
      resources :bookings, only: %i[ index destroy ]
    end
    resources :activities, only: :index
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
