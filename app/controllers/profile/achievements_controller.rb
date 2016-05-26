class Profile::AchievementsController < ApplicationController
  def index
    render json: user.badges, each_serializer: AchievementSerializer
  end

  protected

  def user
    @user ||= Profile.find(params[:profile_id]).user
  end
end
