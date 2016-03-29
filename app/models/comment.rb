class Comment < ApplicationRecord
  include Filterable

  belongs_to :author, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  validates :message, length: { maximum: 200 }

  scope :publics, -> { where(private: false) }

  def self.privates_only(choice)
    where(private: choice.to_s.to_b)
  end
end
