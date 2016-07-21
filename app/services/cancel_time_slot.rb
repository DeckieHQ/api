class CancelTimeSlot < ActionService
  def call
    create_action(:cancel)

    time_slot.destroy
  end

  private

  alias_method :time_slot, :resource
end
