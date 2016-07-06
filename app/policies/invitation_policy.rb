class InvitationPolicy < ApplicationPolicy
  include PolicyMatchers::Event

  alias_method :invitation, :record

  delegate :event, to: :invitation

  def create?
    event.member?(user.profile) && !event_closed?
  end

  def permited_attributes
    [:email, :message]
  end
end
