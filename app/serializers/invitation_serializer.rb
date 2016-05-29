class InvitationSerializer < ActiveModel::Serializer
  attributes :email, :message, :created_at

  belongs_to :profile
  belongs_to :event
end
