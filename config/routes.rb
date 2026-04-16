Rails.application.routes.draw do
  # Onboarding routes (for initial setup) - maps to profiles controller
  get "/onboarding", to: "profiles#new", as: :new_onboarding
  post "/onboarding", to: "profiles#create", as: :onboarding

  # Profile management
  resource :profile, only: [ :show, :update ]

  # API Keys
  resources :api_keys, only: [ :create, :destroy ]

  # API
  namespace :api do
    resources :posts, only: [ :index, :show, :create, :update, :destroy ]
    resource :profile, only: [ :show, :update ], controller: "profile"
  end

  resource :session
  resources :passwords, param: :token

  resources :posts, param: :slug

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end
