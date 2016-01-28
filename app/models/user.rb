require_relative './concerns/acts_as_verifiable'

class User < ApplicationRecord
  before_create :generate_authentication_token

  acts_as_verifiable :email, delivery: UserMailer

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :trackable,
         :validatable

  validates :first_name,   presence: true, length: { maximum: 64 }
  validates :last_name,    presence: true, length: { maximum: 64 }
  validates :birthday,     presence: true, date: {
    after:              Proc.new { Time.now - 100.year },
    before_or_equal_to: Proc.new { Time.now - 18.year  }
  }
  validates :phone_number, uniqueness: true, allow_nil: true
  validates_plausible_phone :phone_number

  private

  def generate_authentication_token
    self.authentication_token = Devise.friendly_token
  end
end
