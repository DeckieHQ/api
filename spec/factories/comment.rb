FactoryGirl.define do
  factory :comment do
    association :author,   factory: :profile
    association :resource, factory: :event

    message { Faker::Lorem.characters(140) }

    factory :comment_invalid do
      message { Faker::Lorem.characters(201) }
    end

    trait :private do
      private true
    end
  end
end
