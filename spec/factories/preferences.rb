FactoryGirl.define do
  factory :preferences do
    notifications { Fake::Preferences.notifications }

    association :user, factory: :user

    factory :preferences_invalid do
      notifications ['unsupported']
    end
  end
end
