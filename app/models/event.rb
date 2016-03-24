class Event < ApplicationRecord
  acts_as_paranoid

  include Filterable

  belongs_to :host, class_name: 'Profile', foreign_key: 'profile_id'

  has_many :submissions

  has_many :confirmed_submissions, -> { confirmed }, class_name: 'Submission'

  has_many :pending_submissions,   -> { pending },   class_name: 'Submission'

  has_many :members, through: :submissions, source: :profile

  has_many :attendees, through: :confirmed_submissions, source: :profile

  has_many :actions, as: :resource

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
    begin_at <= Time.now
  end

  def full?
    attendees_count == capacity
  end

  def switched_to_auto_accept?
    auto_accept_was, auto_accept = previous_changes['auto_accept']

    auto_accept && !auto_accept_was
  end

  def max_confirmable_submissions
    pending_submissions.take(capacity - attendees_count)
  end

  def destroy_pending_submissions
    pending_submissions.destroy_all
  end

  def receivers_for(action)
    case action.type
    when 'subscribe', 'unsubscribe'
      [ host ]
    when 'cancel'
      members.includes(:user)
    when 'join'
      attendees_with_host
    when 'update', 'leave'
      attendees_with_host_except(action.actor)
    else
      throw "Unsupported action: #{action.type}"
    end
  end

  private

  def address_changed?
    street_changed? || city_changed? || state_changed? || country_changed?
  end

  def attendees_with_host
    @attendees_with_host ||= attendees.includes(:user).to_a.push(host)
  end

  def attendees_with_host_except(profile)
    attendees_with_host.delete(profile)

    attendees_with_host
  end
end
