class Action < ApplicationRecord
  belongs_to :actor, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :target, polymorphic: true
end
