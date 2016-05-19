require 'concerns/acts_as_verifiable'

class User < ApplicationRecord
  acts_as_paranoid

  has_one :profile, dependent: :destroy

  has_many :notifications, dependent: :destroy

  delegate :hosted_events, to: :profile

  delegate :opened_hosted_events, to: :profile

  delegate :submissions, to: :profile

  has_secure_token :authentication_token

  after_create :build_profile

  after_update :update_profile, if: :propagate_changes?

  acts_as_verifiable :email,
    delivery: UserMailer, token: -> { Token.friendly }

  acts_as_verifiable :phone_number,
    delivery: UserSMSer,  token: -> { Token.pin }

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :trackable,
         :validatable

  validates :first_name, :last_name, presence: true, length: { maximum: 64 }

  validates :birthday, presence: true, date: {
    after:              Proc.new { 100.year.ago },
    before_or_equal_to: Proc.new {  18.year.ago }
  }
  validates :culture, presence: true, inclusion: { in: %w(en fr) }

  validates_plausible_phone :phone_number

  def verified?
    email_verified? && phone_number_verified?
  end

  def opened_submissions
    submissions.filter({ event: :opened })
  end

  def reset_notifications_count!
    update(notifications_count: 0)
  end

  def subscribed_to?(notification)
    preferences['notifications'].include?(notification.type)
  end

  def host_of?(user)
    user.submissions.confirmed.where(event_id: hosted_events.pluck(:id)).count > 0
  end

  private

  def display_name
    "#{first_name} #{last_name.capitalize.chr}"
  end

  def build_profile
    create_profile(display_name: display_name)
  end

  def update_profile
    profile.update(display_name: display_name,
      email_verified: email_verified?, phone_number_verified: phone_number_verified?
    )
  end

  def propagate_changes?
    first_name_changed?        || last_name_changed?  ||
    email_verified_at_changed? || phone_number_verified_at_changed?
  end
end
