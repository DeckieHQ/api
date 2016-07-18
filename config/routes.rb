require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  Sidekiq::Web.use Rack::Auth::Basic do |username, password|
    username == 'admin' && password == ENV.fetch('JOBS_PASSWORD', 'admin')
  end

  mount Sidekiq::Web , at: '/jobs'

  default_url_options host: ENV['API_URL'] || 'http://api.example.com'

  # Removes all routes first in order to remove routes unnecessary for an API.
  devise_for :users, skip: :all

  scope module: :user do
    devise_scope :user do
      resource :user, controller: :registrations do
        post 'sign_in', to: 'sessions#create'

        resource  :profile,               only: [:show,   :update]
        resource  :password,              only: [:create, :update]
        resource  :verification,          only: [:create, :update]
        resources :hosted_events,         only: [:index,  :create]
        resources :submissions,           only: :index
        resources :time_slot_submissions, only: :index
        resources :notifications,         only: :index

        post 'reset_notifications_count', to: 'notifications#reset_count'
      end
    end
  end

  shallow do
    resources :events, only: [:show, :update, :destroy] do
      resources :submissions, only: [:index, :create, :show, :destroy] do
        post 'confirm', on: :member
      end
      resource :submission, only: :show, controller: 'event/submissions'

      resources :attendees, only: :index, controller: 'event/attendees'

      resources :comments, only: [:index, :create], controller: 'event/comments', shallow: true do
        resources :comments, only: [:index, :create], controller: 'comment/comments'
      end

      resources :invitations, only: :create, controller: 'event/invitations'

      resources :time_slots, only: :index, controller: 'event/time_slots'
    end
  end

  resources :preferences, only: [:show, :update]

  resources :comments, only: [:update, :destroy]

  resources :notifications, only: :show do
    post 'view', on: :member
  end

  resources :profiles, only: [:show, :update] do
    resources :achievements, only: [:index], controller: 'profile/achievements'
  end

  resources :contacts, only: :show

  resources :achievements, only: :show

  resources :feedbacks, only: :create

  resource :location, only: :show

  resources :time_slots, only: [:show, :destroy] do
    resources :members, only: :index, controller: 'time_slot/members'
  end
end
