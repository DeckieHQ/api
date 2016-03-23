class Action < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :actor, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  before_create -> { self.title = title_from_resource }

  after_create :send_notifications

  private

  def title_from_resource
    case resource_type
    when 'Event'
      resource.title
    end
  end

  def send_notifications
    resource.send_notifications_for(self)
  end
end
