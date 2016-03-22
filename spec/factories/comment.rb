FactoryGirl.define do
  factory :comment do
    association :author,   factory: :profile
    association :resource, factory: :event

    message { Faker::Lorem.characters(140) }

    trait :private do
      private true
    end
  end
end
