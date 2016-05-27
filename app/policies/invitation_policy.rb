class InvitationPolicy < ApplicationPolicy
  include PolicyMatchers::Event

  alias_method :invitation, :record

  delegate :event, to: :invitation

  def create?
    event_host? && !event_closed? #already_exist
  end

  def permited_attributes
    [:email, :message]
  end
end
