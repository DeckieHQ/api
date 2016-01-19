class UserSerializer < ActiveModel::Serializer
  attributes :first_name, :last_name, :birthday, :email, :phone_number
end
