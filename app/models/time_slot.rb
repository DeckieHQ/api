class TimeSlot < ApplicationRecord
  belongs_to :event

  after_destroy :reindex_event

  private

  def reindex_event
    ReindexRecordsJob.perform_later('Event', [event.id])
  end
end
