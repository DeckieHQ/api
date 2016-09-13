FactoryGirl.define do
  factory :feedback do
    title { Faker::Lorem.sentence }

    description { Faker::Lorem.paragraph }

    email { [Faker::Internet.email, nil].sample }

    trait :with_invalid_email do
      email { 'test@com' }
    end
  end
end
