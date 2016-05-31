class Profile::AchievementsController < ApplicationController
  def index
    render json: profile.achievements, each_serializer: AchievementSerializer
  end

  protected

  def profile
    @profile ||= Profile.find(params[:profile_id])
  end
end
