FactoryGirl.define do
  factory :action do
    association :actor, factory: :profile_verified

    association :resource, factory: :event

    type { Fake::Action.type }
  end
end
