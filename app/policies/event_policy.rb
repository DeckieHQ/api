class EventPolicy < ApplicationPolicy
  include PolicyMatchers::User
  include PolicyMatchers::Event

  alias_method :event, :record

  def create?
    user_verified?
  end

  def update?
    event_host? && !event_closed?
  end

  def destroy?
    update?
  end

  def subscribe?
    !event_host? && !subscription_already_exist? && !event_closed? && !event_full?
  end

  def subscriptions?
    event_host?
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

  def subscription_already_exist?
    event.subscriptions.find_by(profile: user.profile)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
