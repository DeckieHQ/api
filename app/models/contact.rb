class Contact
  include ActiveModel::Validations
  include ActiveModel::Serialization

  attr_reader :user

  def initialize(user)
    @user = user
  end

  delegate :id,           to: :user
  delegate :email,        to: :user
  delegate :phone_number, to: :user
end
