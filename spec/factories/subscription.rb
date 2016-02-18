FactoryGirl.define do
  factory :subscription do
    association :profile, factory: :profile
  end
end
