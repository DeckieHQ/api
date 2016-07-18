class TimeSlotSerializer < ActiveModel::Serializer
  attributes :begin_at, :created_at

  has_one :event do
    link :related, UrlHelpers.event(object.event_id)

    include_data false
  end
end
