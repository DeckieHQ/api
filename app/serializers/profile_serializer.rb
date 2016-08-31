class ProfileSerializer < ActiveModel::Serializer
  attributes :nickname,
             :display_name,
             :avatar_url,
             :short_description,
             :description,
             :hosted_events_count,
             :moderator,
             :email_verified,
             :phone_number_verified,
             :created_at,
             :deleted_at,
             :deleted

  def avatar_url
    object.avatar.url
  end

  def deleted
    object.deleted?
  end

  has_one :user, key: :contact do
    link :related, UrlHelpers.contact(object.user_id)

    include_data false
  end

  # There is no relation to hit on profiles called achievements, therefore we
  # have to use an existing relationship to generate the link as AMS is trying
  # to call the matching method.
  has_many :submissions, key: :achievements do
    link :related, UrlHelpers.profile_achievements(object)

    include_data false
  end

  has_many :time_slot_submissions do
    link :related, UrlHelpers.profile_time_slot_submissions(object)

    include_data true
  end
end
