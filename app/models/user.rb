class User < ApplicationRecord
  before_create :generate_authentication_token

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :trackable,
         :validatable

  validates :first_name,   presence: true, length: { maximum: 64 }
  validates :last_name,    presence: true, length: { maximum: 64 }
  validates :birthday,     presence: true, date: {
    after:  Proc.new { Time.now - 100.year },
    before: Proc.new { Time.now - 18.year  }
  }
  validates :phone_number, uniqueness: true
  validates_plausible_phone :phone_number

  def generate_authentication_token
    self.authentication_token = Devise.friendly_token
  end
end
