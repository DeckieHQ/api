class Profile < ApplicationRecord
  belongs_to :user

  validates :nickname, length: { maximum: 64 }
  validates :short_description, length: { maximum: 140 }
  validates :description, length: { maximum: 8192 }
end
