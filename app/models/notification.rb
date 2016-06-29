class Notification < ApplicationRecord
  include Filterable

  self.inheritance_column = nil

  belongs_to :user
  belongs_to :action

  before_create :set_type

  after_create :increment_counter_cache

  def self.types
    %w(
      event-submit
      event-unsubmit
      event-leave
      event-comment
      event-update
      event-cancel
      event-join
      event-remove_full
      event-remove_start
      event-ready
      event-not_ready
      comment-comment
    )
  end

  def viewed!
    update(viewed: true)
  end

  private

  def increment_counter_cache
    user.update(notifications_count: user.notifications_count + 1)
  end

  def set_type
    self.type = "#{action.resource_type.downcase}-#{action.type}"
  end
end
