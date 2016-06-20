class PreferencesPolicy < ApplicationPolicy
  alias_method :preferences, :record

  def show?
    preferences_owner?
  end

  def update?
    preferences_owner?
  end

  private

  def preferences_owner?
    preferences.user == user
  end
end
