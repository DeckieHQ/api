class Contact
  include ActiveModel::Validations
  include ActiveModel::Serialization

  attr_reader :user

  def initialize(user)
    @user = user
  end

  def id
    user.id
  end

  delegate :email,        to: :user
  delegate :phone_number, to: :user
end
