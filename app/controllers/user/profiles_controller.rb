class User::ProfilesController < ApplicationController
  before_action :authenticate!

  before_action -> { check_parameters_for :profiles }, only: :update

  before_action :retrieve_profile

  def show
    render_profile
  end

  def update
    unless @profile.update(profile_params)
      return render_validation_errors(@profile)
    end
    render_profile
  end

  protected

  def render_profile
    render json: @profile, status: :ok
  end

  def retrieve_profile
    @profile = current_user.profile
  end

  def profile_params
    resource_attributes.permit(:nickname, :short_description, :description)
  end
end
