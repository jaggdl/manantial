Rails.application.routes.draw do
  # Onboarding routes (for initial setup) - maps to profiles controller
  get "/onboarding", to: "profiles#new", as: :new_onboarding
  post "/onboarding", to: "profiles#create", as: :onboarding

  # Profile management
  resource :profile, only: [ :edit, :update ]

  resource :session
  resources :passwords, param: :token

  resources :posts, param: :slug

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end
