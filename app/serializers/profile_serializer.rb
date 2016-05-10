class ProfileSerializer < ActiveModel::Serializer
  attributes :nickname,
             :display_name,
             :short_description,
             :description,
             :hosted_events_count,
             :created_at,
             :deleted_at,
             :deleted

  def deleted
    object.deleted?
  end
end
