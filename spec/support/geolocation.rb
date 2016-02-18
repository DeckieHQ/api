module GeoLocation
  extend self

  def register(object)
    Geocoder::Lookup::Test.set_default_stub([{
      'latitude':  Faker::Address.latitude,
      'longitude': Faker::Address.longitude,
      'address':   object.address
    }])
  end
end
