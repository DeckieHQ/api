class Submission < ApplicationRecord
  include Filterable

  belongs_to :event
  belongs_to :profile

  enum status: [:pending, :confirmed]

  after_save    :update_counter_cache

  after_destroy :update_counter_cache

  def self.status(status)
    return none unless statuses.has_key?(status)

    where(status: status)
  end

  def self.event(filters)
    joins(:event).merge(Event.filter(filters))
  end

  protected

  def update_counter_cache
    event.update(attendees_count: event.attendees.count)
  end
end
