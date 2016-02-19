FactoryGirl.define do
  factory :subscription do
    association :profile, factory: :profile
    association :event,   factory: :event

    status { Fake::Subscription.status }
  end
end
