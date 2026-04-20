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
  end

  # API Skill documentation for AI agents
  get "/SKILL" => "api/skills#show"
  get "/api/skills/manantial-api.sh" => "api/skills#script"

  # Peer connections — federation API (other instances call these)
  scope "/peers", module: "peers" do
    get "profile", to: "profiles#show", as: :peers_profile
    post "connection", to: "connection_requests#create"
    post "connection/confirm", to: "connection_requests#confirm"
    post "connection/verify", to: "connection_requests#verify"
    post "connection/revoke", to: "connection_requests#revoke"
    delete "connection/:hostname", to: "connection_requests#destroy", constraints: { hostname: /[^\/]+/ }
  end

  # Peer connections — user management UI
  resources :connections, only: [ :index, :create, :destroy ], param: :hostname, constraints: { hostname: /[^\/]+/ }, module: "peers" do
    member do
      post :accept
      post :reject
    end
  end

  resource :session
  resources :passwords, param: :token

  resources :posts, param: :slug

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end
