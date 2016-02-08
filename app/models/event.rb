class Event < ApplicationRecord
  belongs_to :host, class_name: 'Profile', foreign_key: 'profile_id'

  has_many :subscriptions

  has_many :attendees, through: :subscriptions, source: :profile
end
