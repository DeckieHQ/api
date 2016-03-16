class Comment < ApplicationRecord
  belongs_to :author, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true
end
