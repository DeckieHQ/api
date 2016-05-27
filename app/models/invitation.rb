class Invitation < ApplicationRecord
  belongs_to :event

  validates :email, presence: true, email: true

  validates :message, presence: true, length: { maximum: 512 }
end
