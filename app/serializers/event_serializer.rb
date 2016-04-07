class EventSerializer < ActiveModel::Serializer
  attributes :title,
             :category,
             :ambiance,
             :level,
             :capacity,
             :auto_accept,
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
             :attendees_count

  belongs_to :host

  has_many :comments do
    link :related, UrlHelpers.event_comments(object)
    include_data false
  end

  has_many :comments, key: :private_comments do
    link :related, UrlHelpers.event_comments(object) + '?private=true'
    include_data false
  end
end
