require 'concerns/acts_as_verifiable'

class User < ApplicationRecord
  has_merit

  acts_as_paranoid

  has_one :profile, dependent: :destroy

  has_many :notifications, dependent: :destroy

  has_many :email_deliveries, dependent: :destroy

  delegate :hosted_events, to: :profile

  delegate :opened_hosted_events, to: :profile

  delegate :invitations, to: :profile

  delegate :submissions, to: :profile

  delegate :time_slot_submissions, to: :profile

  has_secure_token :authentication_token

  before_create :initialize_preferences

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

  validates :first_name, presence: true, length: { maximum: 64 }

  validates :last_name, presence: true, length: { maximum: 64 }, unless: :organization?

  validates :birthday, presence: true, date: { before_or_equal_to: Proc.new {  18.year.ago } },
    unless: :organization?

  validates :birthday, date: { after: Proc.new { 100.year.ago } },
    if: -> { !persisted? || birthday_changed? }, unless: :organization?

  validates :last_name, :birthday, absence: true, if: :organization?

  validates :culture, presence: true, inclusion: { in: %w(en fr) }

  validates :organization, inclusion: { in: [true, false] }

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

  def host_of?(user)
    user.submissions.confirmed.where(event_id: hosted_events.pluck(:id)).count > 0
  end

  def notifications_to_send
    notifications.where(sent: false, type: preferences['notifications'])
  end

  def welcome
    UserMailer.welcome_informations(self).deliver_later
  end

  def received_email?(type, resource)
    email_deliveries.find_by(type: type, resource: resource)
  end

  def deliver_email(type, resource)
    UserMailer.public_send(type, self, resource).deliver_now

    EmailDelivery.create(type: type, receiver: self, resource: resource)
  end

  def display_name
    organization? ? first_name : "#{first_name} #{last_name.capitalize.chr}"
  end

  private

  def initialize_preferences
    self.preferences = { 'notifications': Notification.types }
  end

  def build_profile
    create_profile(propagation_attributes)
  end

  def update_profile
    profile.update(propagation_attributes)
  end

  def propagation_attributes
    {
      display_name: display_name,
      moderator: moderator?,
      organization: organization?,
      email_verified: email_verified?,
      phone_number_verified: phone_number_verified?
    }
  end

  def propagate_changes?
    first_name_changed?        || last_name_changed?  || moderator_changed? ||
    email_verified_at_changed? || phone_number_verified_at_changed?
  end
end
