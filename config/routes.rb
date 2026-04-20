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
    post "connection", to: "connections#create"
    post "connection/confirm", to: "connections#confirm"
    post "connection/verify", to: "connections#verify"
    post "connection/revoke", to: "connections#revoke"
    delete "connection/:hostname", to: "connections#destroy", constraints: { hostname: /[^\/]+/ }
  end

  # Peer connections — user management UI
  namespace :peers do
    resources :connections, only: [ :index, :create, :destroy ], param: :hostname, constraints: { hostname: /[^\/]+/ }, controller: "connections_management" do
      member do
        post :accept
        post :reject
      end
    end
  end

  resource :session
  resources :passwords, param: :token

  resources :posts, param: :slug

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end
