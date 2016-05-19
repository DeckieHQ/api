class Contact
  include ActiveModel::Validations
  include ActiveModel::Serialization

  def initialize(user)
    @user = user
  end

  def id
    user.id
  end

  delegate :email,        to: :user
  delegate :phone_number, to: :user

  private

  attr_reader :user
end
