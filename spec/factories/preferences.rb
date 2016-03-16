FactoryGirl.define do
  factory :preferences do
    notifications { Fake::Preferences.notifications }

    factory :preferences_invalid do
      notifications ['unsupported']
    end
  end
end
