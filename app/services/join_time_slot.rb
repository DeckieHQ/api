class JoinTimeSlot < ActionService
  def initialize(time_slot, profile)
    super(profile, time_slot)
  end

  def call
    create_action(:join)

    TimeSlotSubmission.create(time_slot: time_slot, profile: profile)
  end

  private

  alias_method :profile, :actor

  alias_method :time_slot, :resource
end
