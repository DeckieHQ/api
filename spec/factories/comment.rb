FactoryGirl.define do
  factory :comment do
    association :author,   factory: :profile

    message { Faker::Lorem.characters(140) }

    factory :comment_invalid do
      message { Faker::Lorem.characters(201) }
    end

    trait :private do
      private true
    end

    transient do
      of_comment false
    end

    after(:build) do |comment, evaluator|
      if evaluator.of_comment
        comment.resource = create(:comment)
      else
        comment.resource = create(:event)
      end
    end
  end
end
