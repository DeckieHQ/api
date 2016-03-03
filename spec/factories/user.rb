FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name  }
    birthday   { Faker::Date.between(100.years.ago + 1.day, 18.years.ago) }

    culture 'en'

    email    { Faker::Internet.email }
    password { Faker::Internet.password }

    factory :user_invalid do
      email nil
    end

    factory :user_with_email_verified do
      after(:create) { |user| user.verify_email! }
    end

    factory :user_with_email_verification do
      after(:create) { |user| user.generate_email_verification_token! }

      factory :user_with_email_verification_expired do
        after(:create) do |user|
          sent_at = Faker::Time.between(10.hours.ago, 6.hours.ago)

          user.update(email_verification_sent_at: sent_at)
        end
      end
    end

    factory :user_with_phone_number do
      phone_number { Fake::PhoneNumber.plausible }

      factory :user_with_phone_number_verified do
        after(:create) { |user| user.verify_phone_number! }
      end

      factory :user_with_phone_number_verification do
        after(:create) { |user| user.generate_phone_number_verification_token! }

        factory :user_with_phone_number_verification_expired do
          after(:create) do |user|
            sent_at = Faker::Time.between(10.hours.ago, 6.hours.ago)

            user.update(phone_number_verification_sent_at: sent_at)
          end
        end
      end

      factory :user_verified do
        after(:create) do |user|
          user.verify_email!
          user.verify_phone_number!
        end

        factory :user_with_hosted_events do
          transient do
            events_count        5
            events_closed_count 2
          end

          after(:create) do |user, e|
            create_list(:event, e.events_count - e.events_closed_count, host: user.profile)
            create_list(:event_closed, e.events_closed_count, host: user.profile)
          end
        end
      end
    end

    trait :with_subscriptions do
      transient do
        subscriptions_count        5
        subscriptions_closed_count 2
      end

      after(:create) do |user, e|
        create_list(:subscription,
          e.subscriptions_count - e.subscriptions_closed_count, profile: user.profile
        )
        create_list(
          :subscription, e.subscriptions_closed_count, :to_event_closed, profile: user.profile
        )
      end
    end
  end
end
