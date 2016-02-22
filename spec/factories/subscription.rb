FactoryGirl.define do
  factory :subscription do
    association :profile, factory: :profile
    association :event,   factory: :event

    status { Fake::Subscription.status }

    factory :subscription_confirmed do
      status 'confirmed'
    end

    factory :subscription_pending do
      status 'pending'
    end
  end
end
