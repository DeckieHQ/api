class UserSerializer < ActiveModel::Serializer
  attributes :first_name,
             :last_name,
             :birthday,
             :email,
             :phone_number,
             :culture,
             :moderator,
             :email_verified,
             :phone_number_verified,
             :notifications_count

  has_one :profile do
    link :related, UrlHelpers.profile(object.profile)

    include_data false
  end

  has_one :preferences do
    link :related, UrlHelpers.preference(object.id)

    include_data false
  end

  has_many :hosted_events do
    link :related, UrlHelpers.user_hosted_events

    include_data false
  end

  has_many :submissions do
    link :related, UrlHelpers.user_submissions

    include_data false
  end

  has_many :notifications do
    link :related, UrlHelpers.user_notifications

    include_data false
  end

  def email_verified
    object.email_verified?
  end

  def phone_number_verified
    object.phone_number_verified?
  end
end
