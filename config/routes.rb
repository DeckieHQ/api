Rails.application.routes.draw do
  default_url_options host: 'http://0.0.0.0:8080'

  # Removes all routes first in order to remove routes unnecessary for an API.
  devise_for :users, skip: :all

  scope module: :user do
    devise_scope :user do
      resource :user, controller: :registrations do
        post '/sign_in', to: 'sessions#create'

        resource  :profile,       only: [:show,   :update]
        resource  :preferences,   only: [:show,   :update]
        resource  :password,      only: [:create, :update]
        resource  :verification,  only: [:create, :update]
        resources :hosted_events, only: [:index,  :create]
        resources :submissions,   only: :index
        resources :notifications, only: :index
      end
    end
  end

  shallow do
    resources :events, only: [:show, :update, :destroy] do
      resources :submissions, only: [:index, :create, :show, :destroy] do
        post 'confirm', on: :member
      end
    end
  end

  resources :notifications, only: :show do
    post 'view', on: :member
  end

  resources :profiles, only: [:show, :update]
end
