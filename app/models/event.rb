class Event < ApplicationRecord
  acts_as_paranoid

  include EventSearch

  include Filterable

  attr_accessor :new_time_slots

  belongs_to :host, -> { with_deleted },
    class_name: 'Profile', foreign_key: 'profile_id', counter_cache: :hosted_events_count

  has_many :submissions, dependent: :destroy

  has_many :pending_submissions, -> { pending }, class_name: 'Submission'

  # There is an issue on has_many :through with paranoid associations, causing it
  # to return a collection including the deleted resources. Using the without_deleted
  # scope resolves this issue.
  has_many :confirmed_submissions, -> { confirmed.without_deleted }, class_name: 'Submission'

  has_many :attendees, through: :confirmed_submissions, source: :profile

  has_many :actions, as: :resource, dependent: :destroy

  has_many :comments, as: :resource, dependent: :destroy

  has_many :public_comments, -> { publics }, as: :resource, class_name: 'Comment'

  has_many :invitations, dependent: :destroy

  has_many :time_slots, dependent: :destroy

  validates :title, :street, presence: true, length: { maximum: 128 }

  validates :short_description, length: { maximum: 256 }

  validates :description, length: { maximum: 8192 }

  validates :category, presence: true, inclusion: {
    in: %w(
      board role-playing card deck-building dice miniature video outdoor
      strategy cooperative ambiance playful tile-based, other
    )
  }
  validates :ambiance, presence: true, inclusion: {
    in: %w(relaxed serious teasing)
  }
  validates :level, presence: true, inclusion: {
    in: %w(beginner intermediate advanced)
  }

  validates :capacity, presence: true, numericality: { only_integer: true,
    greater_than: 0, less_than: 1000, greater_than_or_equal_to: ->(e) { e.attendees_count }
  }

  validates :min_capacity, numericality: { only_integer: true,
    greater_than_or_equal_to: 0, less_than_or_equal_to: ->(e) { e.capacity || e.min_capacity }
  }

  validates :auto_accept, :flexible, :private, inclusion: { in: [true, false] }

  validates :postcode, presence: true, length: { maximum: 10 }

  validates :city, :country, presence: true, length: { maximum: 64 }

  validates :state, length: { maximum: 64 }

  # Non-flexible validations

  validates :begin_at, presence: true, unless: :flexible?

  validates :begin_at, date: { after: Proc.new { Time.now } }, on: :create, unless: :flexible?

  # Allows events closed to be valid.
  validates :begin_at, date: { after: Proc.new { Time.now } }, on: :update,
    if: -> { !flexible? && begin_at_changed? }

  validates :end_at, date: { after: :begin_at }, allow_nil: true, unless: :flexible?

  validates :new_time_slots, absence: true, unless: :flexible?

  # Flexible validations

  validates :begin_at, absence: true, if: :flexible?

  validates :end_at, absence: true, if: :flexible?

  validate :new_time_slots_must_be_valid, on: :create

  geocoded_by :address

  before_save :geocode, if: :address_changed?

  after_create :create_time_slots, if: :flexible?

  scope :with_pending_submissions,
    -> { joins(:submissions).merge(Submission.pending).distinct }

  def self.opened(opened = true)
    sign = opened.to_s.to_b ? '>' : '<='

    where("begin_at #{sign} ?", Time.now)
  end

  def address
    [street, postcode, city, state, country].compact.join(', ')
  end

  def closed?
    !flexible? && begin_at <= Time.now
  end

  def full?
    attendees_count == capacity
  end

  def ready?
    attendees_count >= min_capacity
  end

  def just_ready?
    attendees_count == min_capacity
  end

  def switched_to_auto_accept?
    auto_accept_was, auto_accept = previous_changes['auto_accept']

    auto_accept && !auto_accept_was
  end

  def max_confirmable_submissions
    pending_submissions.take(capacity - attendees_count)
  end

  def receivers_ids_for(action)
    case action.type.to_sym
    when :submit, :unsubmit
      [ host.id ]
    when :cancel
      submissions.pluck('profile_id')
    when :remove_full, :remove_start
      pending_submissions.pluck('profile_id')
    when :join, :ready, :not_ready
      attendees_with_host_ids
    when :update, :leave, :comment
      attendees_with_host_ids_except(action.actor)
    else
      throw "Unsupported action: #{action.type}"
    end
  end

  def member?(profile)
    profile == host || attendees.include?(profile)
  end

  def submission_of(user = nil)
    return unless user

    submissions.find_by(profile: user.profile)
  end

  private

  def address_changed?
    street_changed? || city_changed? || state_changed? || country_changed?
  end

  def attendees_with_host_ids
    @attendees_with_host_ids ||= attendees.pluck('id').push(host.id)
  end

  def attendees_with_host_ids_except(profile)
    attendees_with_host_ids.delete(profile.id)

    attendees_with_host_ids
  end

  def create_time_slots
    new_time_slots.each do |time|
      time_slots << TimeSlot.new(begin_at: time)
    end
  end

  def new_time_slots_must_be_valid
    unless flexible?
      return errors.add(:new_time_slots, :present)  if new_time_slots
    else
      unless new_time_slots.kind_of?(Array) &&
        new_time_slots.tap(&:uniq!).length >= 1 && new_time_slots.length <= 5
        return errors.add(:new_time_slots, :unsupported)
      end
      new_time_slots.each do |time|
        unless time.kind_of?(Time) && time >= Time.now + 1.day
          return errors.add(:new_time_slots, :unsupported)
        end
      end
    end
    true
  end
end
