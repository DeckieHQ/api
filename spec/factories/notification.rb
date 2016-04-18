FactoryGirl.define do
  factory :notification do
    association :user, factory: :user

    association :action, factory: :action

    viewed { Fake::Notification.viewed }

    trait :direct do
      association :action, factory: :action_direct

      before(:create) do |notification|
        notification.user = notification.action.actor.user
      end
    end
  end
end
