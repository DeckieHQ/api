Rails.application.routes.draw do
  default_url_options host: 'www.deckie.io'

  # Removes all routes first in order to remove routes unnecessary for an API.
  devise_for :users, skip: :all

  scope module: :user do
    devise_scope :user do
      resource :user, controller: :registrations do
        post '/sign_in', to: 'sessions#create'

        resource :password,      only: [:create, :update]
        resource :verifications, only: [:create, :update]
        resource :profile,       only: [:show, :update]
      end
    end
  end
end
