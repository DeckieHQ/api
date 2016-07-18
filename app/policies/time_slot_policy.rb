class TimeSlotPolicy < ApplicationPolicy
  include PolicyMatchers::Event

  alias_method :time_slot, :record

  delegate :event, to: :time_slot

  def destroy?
    event_host?
  end
end
