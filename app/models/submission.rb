class Submission < ApplicationRecord
  acts_as_paranoid

  include Filterable

  belongs_to :event, counter_cache: true

  belongs_to :profile, -> { with_deleted }

  enum status: [:pending, :confirmed]

  after_save    :update_counter_cache, if: :status_changed?

  after_destroy :update_counter_cache

  def self.status(status)
    return none unless statuses.has_key?(status)

    where(status: status)
  end

  def self.event(filters)
    joins(:event).merge(Event.filter(filters))
  end

  private

  # This will maybe lead to validations fail when the event is about to start.
  # If this happens, a workaround should be to remove validations on event#start_at
  # if event#attendees_count changed.
  def update_event_counter_cache
    event.update(attendees_count: event.attendees.count)
  end
end
