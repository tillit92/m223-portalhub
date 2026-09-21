Rails.application.routes.draw do
  root "portals#index"

  resource :session, only: %i[ new create destroy ]
  resources :portals, only: %i[ index show ]

  get "up" => "rails/health#show", as: :rails_health_check
end
