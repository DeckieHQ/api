class LocationSerializer < ActiveModel::Serializer
  type 'locations'

  def id
    0
  end

  attributes :latitude, :longitude
end
