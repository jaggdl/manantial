Rails.application.routes.draw do
  devise_for :users

  scope "(:locale)", locale: /en|es/ do
    root "application#index"

    resources :posts, path: 'blog', param: :id do
      member do
        get 'og_image'
      end
    end

    resource :profile

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

    get 'feed', to: 'feed#index'
    get 'analytics', to: 'analytics#index'
  end

  root to: 'application#index', as: :unlocalized_root

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

  resources :users, only: [:new, :create]
end
