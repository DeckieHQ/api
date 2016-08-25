FactoryGirl.define do
  factory :time_slot_submission do
    association :time_slot, factory: :time_slot

    association :profile, factory: :profile
  end
end
