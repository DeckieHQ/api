class PreferencesController < ApplicationController
  before_action :authenticate!

  def show
    authorize preferences

    render json: preferences
  end

  def update
    authorize preferences

    unless preferences.update(preferences_params)
      return render_validation_errors(preferences)
    end

    render json: preferences
  end

  protected

  def preferences
    @preferences ||= Preferences.for(User.find(params[:id]))
  end

  def preferences_params
    attributes(:preferences).permit(notifications: [])
  end
end
