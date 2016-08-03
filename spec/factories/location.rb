FactoryGirl.define do
  factory :location do
    latitude { Faker::Address.latitude }

    longitude { Faker::Address.longitude }

    factory :location_localhost do
      latitude  0.0
      longitude 0.0
    end
  end
end
