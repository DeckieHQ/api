Rails.application.routes.draw do
  default_url_options host: 'www.deckie.io'

  # Removes all routes first in order to remove routes unnecessary for an API.
  devise_for :users, skip: :all

  scope module: :user do
    devise_scope :user do
      resource :user, controller: :registrations do
        post '/sign_in', to: 'sessions#create'

        resource  :profile,       only: [:show, :update]
        resource  :password,      only: [:create, :update]
        resource  :verifications, only: [:create, :update]
        resources :hosted_events
      end
    end
  end

  resources :events, only: :show do
    resources :subscriptions, only: :create
  end
end
