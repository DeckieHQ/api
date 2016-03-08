class UserSerializer < ActiveModel::Serializer
  attributes :first_name,
             :last_name,
             :birthday,
             :email,
             :phone_number,
             :culture,
             :email_verified,
             :phone_number_verified

  def email_verified
    object.email_verified_at.present?
  end

  def phone_number_verified
    object.phone_number_verified_at.present?
  end
end
