FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name  }
    birthday   { Faker::Date.between(100.years.ago + 1.day, 18.years.ago) }

    culture { Fake::User.culture }

    email    { Faker::Internet.email }
    password { Faker::Internet.password }

    preferences { {} }

    moderator false

    factory :user_elder do
      birthday { Faker::Date.between(100.years.ago - 10.day, 100.years.ago) }

      to_create do |user|
        user.save(validate: false)
      end
    end

    factory :user_update do
      moderator { [true, false].sample }
    end

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

        factory :user_verified_after_email_verification do
          after(:create) { |user| user.generate_email_verification_token! }
        end

        factory :user_verified_after_phone_number_verification do
          after(:create) { |user| user.generate_phone_number_verification_token! }
        end
      end
    end

    trait :moderator do
      moderator true
    end

    trait :organization do
      organization true

      last_name nil

      birthday nil
    end

    trait :with_submissions do
      transient do
        submissions_count        5
        submissions_closed_count 2
      end

      after(:create) do |user, e|
        create_list(:submission,
          e.submissions_count - e.submissions_closed_count, profile: user.profile
        )
        create_list(
          :submission, e.submissions_closed_count, :to_event_closed, profile: user.profile
        )
      end
    end

    trait :with_time_slot_submissions do
      transient do
        time_slot_submissions_count 5
      end

      after(:create) do |user, e|
        create_list(:time_slot_submission, e.time_slot_submissions_count, profile: user.profile)
      end
    end

    trait :with_notifications do
      transient do
        notifications_count 5
      end

      after(:create) do |user, e|
        create_list(:notification, e.notifications_count, user: user)
      end
    end

    trait :with_random_subscriptions do
      after(:create) do |user|
        user.update(preferences: { notifications: Fake::Preferences.notifications })
      end
    end
  end
end
