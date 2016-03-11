class ActionSerializer < ActiveModel::Serializer
  attributes :title, :type, :created_at, :updated_at

  belongs_to :actor
  belongs_to :target
end
