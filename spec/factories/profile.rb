FactoryGirl.define do
  factory :profile do
    nickname { Faker::Name.first_name }
    short_description { Faker::Lorem.characters(140) }
    description { Faker::Lorem.characters(8192) }

    factory :profile_invalid do
      nickname { Faker::Lorem.characters(65) }
    end
  end
end
