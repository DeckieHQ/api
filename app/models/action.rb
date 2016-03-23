class Action < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :actor, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  before_create -> { self.title = resource.title }

  after_create :send_notifications

  private

  def send_notifications
    resource.notifiers_for(self).map do |notifier|
      Notification.create(action: self, user: notifier.user)
    end
  end
end
