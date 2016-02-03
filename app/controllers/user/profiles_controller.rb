class User::ProfilesController < ApplicationController
  before_action :authenticate!

  before_action -> { check_root_for :profile }, only: :update

  def show
    render json: current_user.profile, status: :ok
  end

  def update
    
  end
end
