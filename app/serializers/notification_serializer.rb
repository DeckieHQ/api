class NotificationSerializer < ActiveModel::Serializer
  attributes :type, :viewed

  belongs_to :user
  belongs_to :action
end
