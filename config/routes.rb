Rails.application.routes.draw do
  default_url_options host: 'www.deckie.io'

  # Removes all routes first in order to remove routes unnecessary for an API.
  devise_for :users, skip: :all

  devise_scope :user do
    post '/users/sign_in' => 'sessions#create', as: :users_sign_in

    post   '/users' => 'registrations#create',  as: :users_sign_up
    put    '/users' => 'registrations#update',  as: :users_account_update
    delete '/users' => 'registrations#destroy', as: :users_account_cancel

    post '/users/password' => 'passwords#create', as: :users_reset_password_instructions
    put  '/users/password' => 'passwords#update', as: :users_reset_password
  end
end
