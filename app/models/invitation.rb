class Invitation < ApplicationRecord
  validates :email, presence: true, email: true

  validates :message, presence: true, length: { maximum: 512 }
end
