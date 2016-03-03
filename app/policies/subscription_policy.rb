class SubscriptionPolicy < ApplicationPolicy
  include PolicyMatchers::Event

  alias_method :subscription, :record

  delegate :event, to: :subscription

  def show?
    subscription_owner? || event_host?
  end

  def confirm?
    event_host? && !subscription_already_confirmed? && !event_closed? && !event_full?
  end

  def destroy?
    subscription_owner? && !event_closed?
  end

  private

  def subscription_owner?
    user.profile == subscription.profile
  end

  def subscription_already_confirmed?
    add_error(:subscription_already_confirmed) if subscription.confirmed?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
