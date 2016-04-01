class CommentSerializer < ActiveModel::Serializer
  attributes :message, :private, :created_at

  has_many :comments do
    link :related, UrlHelpers.comment_comments(object)
    include_data false
  end
end
