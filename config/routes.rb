Rails.application.routes.draw do
  root "portals#index"

  resource :session, only: %i[ new create destroy ]
  resources :portals, only: %i[ index show ] do
    resources :bookings, only: :create
  end
  resources :bookings, only: %i[ index destroy ]

  namespace :admin do
    resources :portals, except: :show do
      resources :bookings, only: %i[ index destroy ]
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
