class ProfilePolicy < ApplicationPolicy
  alias_method :profile, :record

  def update?
    user.moderator? || profile_owner?
  end

  def permited_attributes
    [
      :nickname,
      :avatar,
      :short_description,
      :description
    ]
  end

  private

  def profile_owner?
    user.profile == profile
  end
end
