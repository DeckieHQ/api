FactoryGirl.define do
  factory :notification do
    association :user, factory: :user

    association :action, factory: :action

    viewed { Fake::Notification.viewed }
  end
end
