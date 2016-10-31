class TimeSlotSubmission < ApplicationRecord
  include Filterable

  belongs_to :time_slot, counter_cache: :members_count

  belongs_to :profile

  after_create :update_counter_cache

  after_destroy :update_counter_cache

  delegate :event, to: :time_slot

  private

  def update_counter_cache
    event.update(attendees_count: event.optimum_time_slot.members_count)
  end
end
