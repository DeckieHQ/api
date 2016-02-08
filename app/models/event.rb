class Event < ApplicationRecord
  belongs_to :host, class_name: 'Profile', foreign_key: 'profile_id'

  has_many :subscriptions

  has_many :attendees, through: :subscriptions, source: :profile

  validates :title,    presence: true, length: { maximum: 128 }

  validates :begin_at, presence: true, date: { before: Proc.new { Time.now } }

  validates :end_at,   presence: true, date: { after: :begin_at }
end
