class SubscriptionPolicy < ApplicationPolicy
  def show?
    owner? || event_host?
  end

  def confirm?
    event_host? && !record.confirmed? && !event.closed? && !event.full?
  end

  def destroy?
    owner? && !event.closed?
  end

  private

  def owner?
    user.profile == record.profile
  end

  def event_host?
    user.profile == event.host
  end

  def event
    @event ||= record.event
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
