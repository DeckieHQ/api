class ProfileSerializer < ActiveModel::Serializer
  attributes :nickname,
             :display_name,
             :avatar_url,
             :short_description,
             :description,
             :hosted_events_count,
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
end
