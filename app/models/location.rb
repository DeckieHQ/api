class Location
  include ActiveModel::Serialization

  attr_accessor :latitude, :longitude

  def initialize(data = {})
    @latitude  = data['latitude'].to_f
    @longitude = data['longitude'].to_f
  end
end
