FactoryGirl.define do
  factory :comment do
    association :author,   factory: :profile
    association :resource, factory: :event

    message { Faker::Lorem.characters(140) }
  end
end
