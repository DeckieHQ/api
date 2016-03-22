class CommentSerializer < ActiveModel::Serializer
  attributes :message, :private, :created_at
end
