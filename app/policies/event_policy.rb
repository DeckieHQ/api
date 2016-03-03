class EventPolicy < ApplicationPolicy
  def create?
    user.verified?
  end

  def update?
    host? && !record.closed?
  end

  def destroy?
    update?
  end

  def subscribe?
    !record.closed? && !record.full? && !host? && !already_subscribed?
  end

  def subscriptions?
    host?
  end

  def permited_attributes
    [
      :title,
      :category,
      :ambiance,
      :level,
      :capacity,
      :auto_accept,
      :description,
      :begin_at,
      :end_at,
      :street,
      :postcode,
      :city,
      :state,
      :country
    ]
  end

  private

  def already_subscribed?
    record.subscriptions.find_by(profile: user.profile)
  end

  def host?
    record.host == user.profile
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
