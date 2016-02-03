FactoryGirl.define do
  factory :profile do
    nickname { Faker::Name.first_name }
  end
end
