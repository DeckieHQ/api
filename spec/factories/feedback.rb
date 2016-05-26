FactoryGirl.define do
  factory :feedback do
    title { Faker::Lorem.sentence }

    description { Faker::Lorem.paragraph }
  end
end
