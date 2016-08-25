class TimeSlotSerializer < ActiveModel::Serializer
  attributes :begin_at, :created_at, :members_count, :full, :member

  alias_method :current_user, :scope

  has_one :event do
    link :related, UrlHelpers.event(object.event_id)

    include_data false
  end

  has_many :members do
    link :related, UrlHelpers.time_slot_members(object)
    include_data false
  end

  has_many :time_slot_submissions do
    link :related, UrlHelpers.time_slot_time_slot_submissions(object)
    include_data false
  end

  def full
    object.full?
  end

  def member
    current_user.present? && object.member?(current_user.profile)
  end
end
