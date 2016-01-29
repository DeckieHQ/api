FactoryGirl.define do
  factory :user do
    first_name 'Jean'
    last_name 'Malakof'
    birthday '09/11/1988'

    email 'jean@yopmail.com'
    password 'azieoj092'

    factory :user_with_email_verified do
      after(:create) { |user| user.verify_email! }
    end

    factory :user_with_email_verification do
      after(:create) { |user| user.generate_email_verification_token! }

      factory :user_with_email_verification_expired do
        after(:create) do |user|
          user.update(email_verification_sent_at: Time.now - 6.hours)
        end
      end
    end

    factory :user_with_phone_number do
      phone_number '+33687654321'

      factory :user_with_phone_number_verified do
        after(:create) { |user| user.verify_phone_number! }
      end

      factory :user_with_phone_number_verification do
        after(:create) { |user| user.generate_phone_number_verification_token! }

        factory :user_with_phone_number_verification_expired do
          after(:create) do |user|
            user.update(phone_number_verification_sent_at: Time.now - 6.hours)
          end
        end
      end
    end
  end

  # This user is not meant to be created. It's sole purpose is to use its
  # attributes to update an existing user (like in account update tests).
  factory :user_update, class: User do
    first_name 'Jean-Luc'
    last_name 'Robert'
    birthday '09/12/1990'
    phone_number '+33612345678'

    email 'jean.luc@yopmail.com'
    password 'plop1234'

    factory :user_update_invalid do
      email '.'
      phone_number '.'
    end
  end
end
