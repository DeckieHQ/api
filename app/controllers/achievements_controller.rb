class AchievementsController < ApplicationController
  def show
    render json: achievement, serializer: AchievementSerializer
  end

  protected

  def achievement
    @achievement ||= Merit::Badge.find(params[:id].to_i)
  end
end
