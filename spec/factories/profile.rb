FactoryGirl.define do
  factory :profile do
    nickname { Faker::Name.first_name }

    factory :profile_invalid do
      nickname { Faker::Lorem.characters(65) }
    end
  end
end
