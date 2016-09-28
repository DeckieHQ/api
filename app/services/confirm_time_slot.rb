class ConfirmTimeSlot < ActionService
  def call
    create_action(:confirm)

    JoinEvent.for(event, time_slot.members)

    event.update(type: :normal, begin_at: time_slot.begin_at)

    event.time_slots.destroy_all
  end

  private

  alias_method :time_slot, :resource

  delegate :event, to: :time_slot
end
