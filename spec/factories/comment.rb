FactoryGirl.define do
  factory :comment do
    association :author,   factory: :profile
    association :resource, factory: :event

    message { Faker::Lorem.characters(140) }

    factory :comment_invalid do
      message { Faker::Lorem.characters(201) }
    end

    trait :private do
      private true
    end

    trait :of_comment do
      association :resource, factory: :comment
    end

    trait :of_recurrent_event do
      association :resource, factory: [:event, :recurrent]
    end

    trait :with_comments do
      transient { comments_count 4 }

      after(:create) do |comment, evaluator|
        create_list(:comment, evaluator.comments_count / 2, resource: comment)
        create_list(:comment, evaluator.comments_count / 2, :private, resource: comment)
      end
    end
  end
end
