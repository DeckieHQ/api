class EventSerializer < ActiveModel::Serializer
  attributes :title,
             :category,
             :ambiance,
             :level,
             :capacity,
             :auto_accept,
             :short_description,
             :description,
             :begin_at,
             :end_at,
             :latitude,
             :longitude,
             :street,
             :postcode,
             :city,
             :state,
             :country,
             :attendees_count,
             :submissions_count,
             :opened,
             :full

  belongs_to :host

  has_many :comments do
    link :related, UrlHelpers.event_comments(object)
    include_data false
  end

  has_many :comments, key: :private_comments do
    link :related, UrlHelpers.event_comments(object) + '?private=true'
    include_data false
  end

  def opened
    !object.closed?
  end

  def full
    object.full?
  end
end
