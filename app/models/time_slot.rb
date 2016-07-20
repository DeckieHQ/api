class TimeSlot < ApplicationRecord
  include Filterable

  belongs_to :event

  has_many :time_slot_submissions, dependent: :destroy

  has_many :members, through: :time_slot_submissions, source: :profile

  after_destroy :reindex_event

  def member?(profile)
    members.find_by(id: profile.id)
  end

  def full?
    members_count == event.capacity
  end

  def closed?
    begin_at <= Time.now
  end

  private

  def reindex_event
    ReindexRecordsJob.perform_later('Event', [event.id])
  end
end
