class Profile < ApplicationRecord
  acts_as_paranoid

  belongs_to :user

  validates :nickname,          length: { maximum: 64   }
  validates :short_description, length: { maximum: 140  }
  validates :description,       length: { maximum: 8192 }

  has_many :submissions

  has_many :hosted_events, class_name: :Event
end
