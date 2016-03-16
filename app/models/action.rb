class Action < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :actor, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  before_create -> { self.title = title_from_resource }

  private

  def title_from_resource
    case resource_type
    when 'Event'
      resource.title
    else
      ''
    end
  end
end
