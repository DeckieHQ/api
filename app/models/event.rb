class Event < ApplicationRecord
  acts_as_paranoid

  self.inheritance_column = nil

  include EventSearch

  include Filterable

  attr_accessor :new_time_slots

  enum type: [:normal, :flexible, :recurrent]

  belongs_to :host, -> { with_deleted },
    class_name: 'Profile', foreign_key: 'profile_id', counter_cache: :hosted_events_count

  belongs_to :parent, -> { with_deleted },
    class_name: 'Event', foreign_key: 'event_id', counter_cache: :children_count

  has_many :children, class_name: 'Event'

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
  }, unless: :unlimited_capacity?

  validates :capacity, absence: true, if: :unlimited_capacity?

  validates :min_capacity, numericality: { only_integer: true,
    greater_than_or_equal_to: 0, less_than_or_equal_to: ->(e) { e.capacity || e.min_capacity }
  }

  validates :auto_accept, :private, :unlimited_capacity, inclusion: { in: [true, false] }

  validates :postcode, presence: true, length: { maximum: 10 }

  validates :city, :country, presence: true, length: { maximum: 64 }

  validates :state, length: { maximum: 64 }

  validates :type, inclusion: { in: types.keys }

  # Normal validations

  validates :begin_at, presence: true, if: :normal?

  # Allows events closed to be valid.
  validates :begin_at, date: { after: Proc.new { Time.now } }, if: :normal?,
    unless: -> { persisted? && !begin_at_changed? }

  validates :end_at, date: { after: :begin_at }, allow_nil: true, if: :normal?

  validates :new_time_slots, absence: true, if: :normal?

  # Flexible and Recurrent validations

  validates :begin_at, absence: true, unless: :normal?

  validates :end_at, absence: true, unless: :normal?

  validates :new_time_slots, presence: true, multiple_times: { min: 2, max: 5, after: 1.day },
    on: :create, if: :flexible?

  validates :new_time_slots, presence: true, multiple_times: { min: 2, max: 200, after: 1.day },
    on: :create, if: :recurrent?

  # Address

  geocoded_by :address

  before_save :geocode, if: :address_changed?

  # Flexible

  before_create :assign_begin_at_range, if: :flexible?

  after_create :create_time_slots, if: :flexible?

  scope :with_pending_submissions,
    -> { joins(:submissions).merge(Submission.pending).distinct }

  # Recurrent

  after_create :create_children, if: :recurrent?

  def self.opened(opened = true)
    if opened.to_s.to_b
      where("type != ? OR begin_at > ?", types['normal'], Time.now)
    else
      where(type: :normal).where('begin_at <= ?', Time.now)
    end
  end

  def self.confirmable_in(percentage:)
    joins(:time_slots).where(
      "time_slots.begin_at - ((time_slots.begin_at - time_slots.created_at) * #{percentage} / 100) <= ?", Time.now
    )
  end

  def self.type(type)
    where(type: type)
  end

  def self.not_type(type)
    where.not(type: type)
  end

  def optimum_time_slot
    time_slots.order('begin_at ASC').max_by(&:members_count)
  end

  def address
    [street, postcode, city, state, country].compact.join(', ')
  end

  def closed?
    normal? && begin_at <= Time.now
  end

  def full?
    !unlimited_capacity? && attendees_count == capacity
  end

  def reached_time_slot_min?
    time_slots.count == 2
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

  def time_slots_members
    Profile.where(
      id: TimeSlotSubmission.where(time_slot_id: time_slots.pluck('id')).pluck('profile_id')
    ).distinct
  end

  def top_resource ; self ; end

  def receivers_ids_for(action)
    case action.type.to_sym
    when :submit, :unsubmit
      [ host.id ]
    when :cancel
      if flexible?
        time_slots_members.pluck('id')
      else
        submissions.pluck('profile_id')
      end
    when :remove_full, :remove_start
      pending_submissions.pluck('profile_id')
    when :join, :ready, :not_ready
      attendees_with_host_ids
    when :update, :leave, :comment
      attendees_with_host_ids.tap { |ids| ids.delete(action.actor.id) }
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

  def assign_begin_at_range
    self.begin_at_range = { min: new_time_slots.min, max: new_time_slots.max }
  end

  def create_time_slots
    new_time_slots.each do |time|
      time_slots << TimeSlot.new(begin_at: time)
    end
  end

  def create_children
    new_time_slots.each do |time|
      children << Event.new(propagation_attributes.merge({ begin_at: time }))
    end
  end

  def propagation_attributes
    attributes.except('id').except('children_count').merge({ 'type': :normal })
  end
end
