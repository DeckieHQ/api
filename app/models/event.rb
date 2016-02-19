class Event < ApplicationRecord
  include Filterable

  belongs_to :host, class_name: 'Profile', foreign_key: 'profile_id'

  has_many :subscriptions, dependent: :destroy

  has_many :confirmed_subscriptions, -> { confirmed }, class_name: 'Subscription'

  has_many :attendees, through: :confirmed_subscriptions, source: :profile

  validates :title, :street, presence: true, length: { maximum: 128 }

  validates :description, length: { maximum: 8192 }

  validates :category, presence: true, inclusion: {
    in: %w(party board role-playing card dice miniature strategy cooperative video tile-based)
  }
  validates :ambiance, presence: true, inclusion: {
    in: %w(serious relaxed party)
  }
  validates :level, presence: true, inclusion: {
    in: %w(beginner intermediate advanced expert)
  }

  validates :capacity, presence: true, numericality: { only_integer: true,
    greater_than: 0, less_than: 1000, greater_than_or_equal_to: ->(e) { e.attendees_count }
  }
  validates :auto_accept, inclusion: { in: [true, false] }

  validates :begin_at, presence: true, date: { after: Proc.new { Time.now } }
  validates :end_at, date: { after: :begin_at }, allow_nil: true

  validates :postcode, presence: true, length: { maximum: 10 }

  validates :city, :country, presence: true, length: { maximum: 64 }

  validates :state, length: { maximum: 64 }

  geocoded_by :address

  before_save :geocode, if: :address_changed?

  def self.opened(opened = true)
    sign = opened.to_s.to_b ? '>' : '<='

    where("begin_at #{sign} ?", Time.now)
  end

  def address
    [street, postcode, city, state, country].compact.join(', ')
  end

  def closed?
    errors.add(:base, :closed) if begin_at <= Time.now
  end

  def full?
    errors.add(:base, :full) if attendees_count == capacity
  end

  protected

  def address_changed?
    street_changed? || city_changed? || state_changed? || country_changed?
  end
end
