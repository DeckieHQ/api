Rails.application.routes.draw do
  # Removes all routes first in order to remove routes unnecessary for an API.
  devise_for :users, skip: :all

  devise_scope :user do
    post '/users/sign_in' => 'sessions#create', as: :users_sign_in

    post   '/users' => 'registrations#create',  as: :users_sign_up
    put    '/users' => 'registrations#update',  as: :users_account_update
    delete '/users' => 'registrations#destroy', as: :users_account_cancel
  end
end
