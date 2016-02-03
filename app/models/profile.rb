class Profile < ApplicationRecord
  belongs_to :user

  validates :nickname, length: { maximum: 64 }
end
