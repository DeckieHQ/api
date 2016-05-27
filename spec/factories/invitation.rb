FactoryGirl.define do
  factory :invitation do
    association :event, factory: :event

    email { Faker::Internet.email }

    message { Faker::Lorem.paragraph }

    trait :with_invalid_email do
      email { 'test@com' }
    end
  end
end
