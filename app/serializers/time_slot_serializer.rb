class TimeSlotSerializer < ActiveModel::Serializer
  attributes :begin_at, :created_at, :full

  has_one :event do
    link :related, UrlHelpers.event(object.event_id)

    include_data false
  end

  has_many :members do
    link :related, UrlHelpers.time_slot_members(object)
    include_data false
  end

  def full
    object.full?
  end
end
