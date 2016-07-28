class TimeSlot < ApplicationRecord
  include Filterable

  belongs_to :event

  has_many :time_slot_submissions, dependent: :destroy

  has_many :members, through: :time_slot_submissions, source: :profile

  after_destroy :update_event_begin_at_range

  def title
    "#{event.title} - #{begin_at}"
  end

  def member?(profile)
    members.find_by(id: profile.id).present?
  end

  def full?
    members_count == event.capacity
  end

  def closed?
    begin_at <= Time.now
  end

  def limit?
    event.time_slots.count == 2
  end

  def receivers_ids_for(action)
    case action.type.to_sym
    when :join, :leave
      [ event.host.id ]
    when :cancel
      members.pluck('id')
    when :confirm
      TimeSlotSubmission.where(
        time_slot_id: event.time_slots.pluck('id')
      ).pluck('id')
    else
      throw "Unsupported action: #{action.type}"
    end
  end

  private

  def update_event_begin_at_range
    begin_at_values = event.time_slots.pluck(:begin_at)

    event.update(begin_at_range: { min: begin_at_values.min, max: begin_at_values.max })
  end
end
