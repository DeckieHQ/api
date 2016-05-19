class ContactSerializer < ActiveModel::Serializer
  attributes :email, :phone_number
end
