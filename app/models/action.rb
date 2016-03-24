class Action < ApplicationRecord
  self.inheritance_column = nil

  attr_accessor :notify

  belongs_to :actor, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  before_create -> { self.title = resource.title }

  after_create :create_notifications

  def resource
    resource_type.constantize.unscoped { super }
  end

  private

  def create_notifications
    case notify
    when :now
      ActionNotifierJob.perform_now(self)
    when :later
      ActionNotifierJob.perform_later(self)
    end
  end
end
