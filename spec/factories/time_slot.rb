FactoryGirl.define do
  factory :time_slot do
    begin_at { Fake::TimeSlot.begin_at }

    association :event, factory: [:event, :flexible]
  end
end
