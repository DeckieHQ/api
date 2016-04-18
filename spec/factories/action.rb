FactoryGirl.define do
  factory :action do
    association :actor, factory: :profile_verified

    association :resource, factory: :event

    notify :never

    after(:build) do |action|
      action.type = Fake::Action.type_for(action.resource_type)
    end

    factory :action_direct do
      association :resource, factory: :event

      after(:build) do |action|
        action.type = Fake::Action.type_for(action.resource_type, direct: true)
      end
    end

    trait :of_event_with_submissions do
      association :resource, factory: :event_with_submissions
    end
  end
end
