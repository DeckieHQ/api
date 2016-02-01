Rails.application.routes.draw do
  default_url_options host: 'www.deckie.io'

  # Removes all routes first in order to remove routes unnecessary for an API.
  devise_for :users, skip: :all

  namespace :users do
    devise_scope :user do
      post '/sign_in', to: 'sessions#create', as: :sign_in

      post   '/', to: 'registrations#create'
      get    '/', to: 'registrations#show'
      match  '/', to: 'registrations#update', via: [:put, :patch]
      delete '/', to: 'registrations#destroy'

      resource :password,      only: [:create, :update], as: :reset_password
      resource :verifications, only: [:create, :update]
    end
  end
end
