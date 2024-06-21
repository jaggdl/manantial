Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root "application#index"

  resources :posts, path: 'blog', param: :id
  resources :users, only: [:new, :create]
end
