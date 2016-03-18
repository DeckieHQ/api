class User::PreferencesController < ApplicationController
  before_action :authenticate!

  def show
    render_user_preferences
  end

  def update
    preferences = Preferences.new(preferences_params)

    return render_validation_errors(preferences) unless preferences.valid?

    current_user.update(preferences: preferences.attributes)

    render_user_preferences
  end

  protected

  def render_user_preferences
    render json: Preferences.new(current_user.preferences)
  end

  def preferences_params
    attributes(:preferences).permit(notifications: [])
  end
end
