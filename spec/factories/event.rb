FactoryGirl.define do
  factory :event do
    title { Faker::Lorem.sentence }

    category { Fake::Event.category }

    ambiance { Fake::Event.ambiance }

    level { Fake::Event.level }

    capacity { Faker::Number.between(1, 999) }

    description { Faker::Lorem.paragraph }

    begin_at { Faker::Time.between(Time.now, Time.now + 10.day, :all) }

    end_at { Faker::Time.between(Time.now + 10.day, Time.now + 20.day, :all) }

    street   { Faker::Address.street_address }
    postcode { Faker::Address.postcode       }
    city     { Faker::Address.country        }
    state    { Faker::Address.state          }
    country  { Faker::Address.country        }

    auto_accept false

    association :host, factory: :profile_verified

    trait :auto_accept do
      auto_accept true
    end

    trait :with_pending_subscriptions do
      transient { pendings_count 5 }

      after(:create) do |event, evaluator|
        create_list(:subscription, evaluator.pendings_count, :pending, event: event)
      end
    end

    factory :event_closed do
      begin_at { Faker::Time.backward(5, :all) }

      to_create do |event|
        event.save(validate: false)
      end
    end

    factory :event_with_subscriptions do
      transient { subscriptions_count 10 }

      before(:create) do |event, evaluator|
        event.capacity = evaluator.subscriptions_count * 2
      end

      after(:create) do |event, evaluator|
        create_list(:subscription, evaluator.subscriptions_count, event: event)
      end
    end

    factory :event_with_attendees do
      transient { attendees_count 10 }

      before(:create) do |event, evaluator|
        event.capacity = evaluator.attendees_count * 2
      end

      after(:create) do |event, evaluator|
        create_list(:subscription, evaluator.attendees_count, :confirmed, event: event)
      end

      factory :event_with_one_slot_remaining do
        after(:create) do |event, evaluator|
          event.update(capacity: evaluator.attendees_count + 1)
        end
      end

      factory :event_full do
        after(:create) do |event, evaluator|
          event.capacity = evaluator.attendees_count
          event.save(validate: false)
        end
      end
    end

    after(:build) do |event|
      GeoLocation.register(event)
    end
  end
end
