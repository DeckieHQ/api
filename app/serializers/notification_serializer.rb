class NotificationSerializer < ActiveModel::Serializer
  attributes :type, :created_at, :updated_at

  belongs_to :user
  belongs_to :action
end
