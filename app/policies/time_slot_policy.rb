class TimeSlotPolicy < ApplicationPolicy
  include PolicyMatchers::Event

  alias_method :time_slot, :record

  delegate :event, to: :time_slot

  def confirm?
    event_host? && !time_slot_closed?
  end

  def destroy?
    event_host?
  end

  def join?
    !event_host? && !time_slot_submission_already_exist? && !time_slot_full?
  end

  private

  def time_slot_submission_already_exist?
    add_error(:time_slot_submission_already_exist) if time_slot.member?(user.profile)
  end

  def time_slot_full?
    add_error(:time_slot_full) if time_slot.full?
  end

  def time_slot_closed?
    add_error(:time_slot_closed) if time_slot.closed?
  end
end
