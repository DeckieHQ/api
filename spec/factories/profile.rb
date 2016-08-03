def bind(profile, factory_name)
  user = create(factory_name)

  user.profile.really_destroy!

  profile.user_id = user.id

  profile.save

  user.reload.send(:update_profile)

  profile.reload
end

FactoryGirl.define do
  factory :profile do
    nickname          { Faker::Team.creature }
    short_description { Faker::Lorem.sentence }
    description       { Faker::Lorem.paragraph }

    factory :profile_invalid do
      nickname { Faker::Lorem.characters(65) }
    end

    after(:create) do |profile|
      bind(profile, :user)
    end

    factory :profile_verified do
      after(:create) do |profile|
        bind(profile, :user_verified)
      end

      factory :profile_with_hosted_events do
        transient do
          events_count        5
          events_closed_count 2
        end

        after(:create) do |profile, e|
          create_list(:event, e.events_count - e.events_closed_count, host: profile)
          create_list(:event_closed, e.events_closed_count, host: profile)
        end
      end
    end

    trait :with_avatar do
      avatar { File.open(Rails.root.join('spec/support/images/avatar.jpeg')) }
    end

    trait :with_invalid_avatar do
      avatar { File.open(Rails.root.join('Gemfile')) }
    end

    trait :with_achievements do
      after(:create) do |profile|
        3.times do
          profile.user.add_badge(Faker::Number.between(1, 3))
        end
      end
    end

    trait :with_time_slot_submissions do
      transient do
        time_slot_submissions_count 5
      end

      after(:create) do |profile, e|
        create_list(:time_slot_submission, e.time_slot_submissions_count, profile: profile)
      end
    end
  end
end
