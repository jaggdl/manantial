Rails.application.routes.draw do
  devise_for :users
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  scope "(:locale)", locale: /en|es/ do
    # Defines the root path route ("/")
    root "application#index"

    resources :posts, path: 'blog', param: :id do
      member do
        get 'og_image'
      end
    end

    get 'analytics', to: 'analytics#index'
  end

  # Define routes without locale
  root to: 'application#index', as: :unlocalized_root

  resource :profile
  resources :profiles

  namespace :connection do
    resources :out
    resources :set

    resources :in do
      member do
        patch :approve
      end
    end
  end

  resources :connections

  namespace :api do
    namespace :v1 do
      resources :public do
        member do
          get 'info'
        end
      end

      resource :private do
        get 'latest_posts', to: 'private#latest_posts'
      end
    end
  end

  get 'feed', to: 'feed#index'

  resources :users, only: [:new, :create]
end
