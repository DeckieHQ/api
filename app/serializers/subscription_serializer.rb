class SubscriptionSerializer < ActiveModel::Serializer
  attributes :status, :created_at, :updated_at

  belongs_to :profile
  belongs_to :event
end
