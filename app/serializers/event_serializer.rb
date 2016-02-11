class EventSerializer < ActiveModel::Serializer
  attributes :title,
             :category,
             :ambiance,
             :level,
             :capacity,
             :invite_only,
             :description,
             :begin_at,
             :end_at,
             :latitude,
             :longitude,
             :street,
             :postcode,
             :city,
             :state,
             :country
end
