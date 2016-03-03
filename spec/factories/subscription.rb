FactoryGirl.define do
  factory :subscription do
    association :profile, factory: :profile
    association :event,   factory: :event

    status { Fake::Subscription.status }

    trait :pending do
      status 'pending'
    end

    trait :confirmed do
      status 'confirmed'
    end

    trait :to_event_closed do
      association :event, factory: :event_closed
    end

    trait :to_event_full do
      status 'pending'

      association :event, factory: :event_full
    end
  end
end
