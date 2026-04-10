Rails.application.routes.draw do
  resource :onboarding, only: [ :new, :create ]
  resource :session
  resources :passwords, param: :token

  resources :posts, param: :slug

  get "up" => "rails/health#show", as: :rails_health_check

  root "posts#index"
end
