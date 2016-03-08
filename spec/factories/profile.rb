def bind(profile, factory_name)
  user = create(factory_name)

  user.profile.destroy

  profile.user_id = user.id

  profile.save
end

FactoryGirl.define do
  factory :profile do
    nickname          { Faker::Name.first_name }
    short_description { Faker::Lorem.characters(140) }
    description       { Faker::Lorem.characters(8192) }

    factory :profile_invalid do
      nickname { Faker::Lorem.characters(65) }
    end

    before(:create) do |profile|
      bind(profile, :user)
    end

    factory :profile_verified do
      before(:create) do |profile|
        bind(profile, :user_verified)
      end
    end
  end
end
