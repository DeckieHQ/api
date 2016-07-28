class EventSerializer < ActiveModel::Serializer
  attributes :title,
             :category,
             :ambiance,
             :level,
             :capacity,
             :min_capacity,
             :auto_accept,
             :short_description,
             :description,
             :begin_at,
             :end_at,
             :begin_at_range,
             :latitude,
             :longitude,
             :street,
             :postcode,
             :city,
             :state,
             :country,
             :attendees_count,
             :submissions_count,
             :public_comments_count,
             :private_comments_count,
             :private,
             :flexible,
             :reached_time_slot_min,
             :opened,
             :full,
             :ready

  belongs_to :host

  has_many :attendees do
    link :related, UrlHelpers.event_attendees(object)
    include_data false
  end

  has_one :submission_of, key: :user_submission do
    link :related, UrlHelpers.event_submission(object)
    include_data false
  end

  has_many :submissions do
    link :related, UrlHelpers.event_submissions(object)
    include_data false
  end

  has_many :invitations do
    link :related, UrlHelpers.event_invitations(object)
    include_data false
  end

  has_many :comments do
    link :related, UrlHelpers.event_comments(object)
    include_data false
  end

  has_many :time_slots do
    link :related, UrlHelpers.event_time_slots(object)
    include_data false
  end

  def opened
    !object.closed?
  end

  def full
    object.full?
  end

  def ready
    object.ready?
  end

  def reached_time_slot_min
    object.reached_time_slot_min?
  end
end
