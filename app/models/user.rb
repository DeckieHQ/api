class User < ApplicationRecord
  before_create :generate_authentication_token

  before_update :reset_email_verification, if: :email_changed?

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

  def generate_email_verification_token!
    self.email_verification_token   = fiendly_token
    self.email_verification_sent_at = Time.now
    self.save
  end

  def verify_email!
    self.email_verification_token = nil
    self.email_verified_at = Time.now
    self.save
  end

  def send_email_verification_instructions
    UserMailer.email_verification_instructions(self).deliver_now
  end

  private

  def generate_authentication_token
    self.authentication_token = fiendly_token
  end

  def reset_email_verification
    self.email_verification_token = nil
    self.email_verification_sent_at = nil
    self.email_verified_at = nil
  end

  def fiendly_token
    Devise.friendly_token
  end
end
