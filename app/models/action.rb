class Action < ApplicationRecord
  belongs_to :actor, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :target, polymorphic: true

  before_create -> { self.title = title_from_target }

  private

  def title_from_target
    case target_type
    when 'Event'
      target.title
    else
      ''
    end
  end
end
