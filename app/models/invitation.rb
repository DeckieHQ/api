class Invitation < ApplicationRecord
  belongs_to :profile
  belongs_to :event

  validates :email, presence: true, email: true, uniqueness: { scope: :event_id, case_sensitive: false }

  validates :message, presence: true, length: { maximum: 512 }
end
