class Invitation < ApplicationRecord
  belongs_to :sender, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :event

  delegate :user, to: :sender

  validates :email, presence: true, email: true, uniqueness: { scope: :event_id, case_sensitive: false }

  validates :message, presence: true, length: { maximum: 512 }

  def send_informations
    InvitationMailer.informations(self).deliver_now
  end
end
