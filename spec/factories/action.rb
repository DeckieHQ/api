FactoryGirl.define do
  factory :action do
    association :actor, factory: :profile_verified

    association :resource, factory: :event

    notify :never

    after(:build) do |action|
      action.type = Fake::Action.type_for(action.resource_type)
    end
  end
end
