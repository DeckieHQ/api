class ProfilesController < ApplicationController
  before_action :authenticate!, only: [:update]

  def show
    render json: profile
  end

  def update
    authorize profile

    unless profile.update(profile_params)
      return render_validation_errors(profile)
    end
    render json: profile
  end

  protected

  def profile
    @profile ||= Profile.find(params[:id])
  end

  def profile_params
    permited_attributes(profile)
  end
end
