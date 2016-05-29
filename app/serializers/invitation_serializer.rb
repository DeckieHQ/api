class InvitationSerializer < ActiveModel::Serializer
  attributes :email, :message, :created_at

  belongs_to :sender
  belongs_to :event
end
