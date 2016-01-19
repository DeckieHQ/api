FactoryGirl.define do
  factory :user do
    first_name 'Jean'
    last_name 'Malakof'
    birthday '09/11/1988'

    email 'jean@yopmail.com'
    password 'azieoj092'
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
