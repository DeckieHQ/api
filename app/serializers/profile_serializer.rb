class ProfileSerializer < ActiveModel::Serializer
  attributes :nickname,
             :display_name,
             :short_description,
             :description
end
