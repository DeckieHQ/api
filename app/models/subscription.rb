class Subscription < ApplicationRecord
  belongs_to :event
  belongs_to :profile

  enum status: [ :pending, :confirmed, :refused ]

  after_save    :update_counter_cache

  after_destroy :update_counter_cache

  protected

  def update_counter_cache
    event.update(attendees_count: event.attendees.count)
  end
end
