FactoryGirl.define do
  factory :page do
    number Faker::Number.between(1, 1000)
    size   Faker::Number.between(1, 50)

    factory :page_invalid do
      number -1
    end

    factory :page_default do
      number 1
      size   10
    end
  end
end
