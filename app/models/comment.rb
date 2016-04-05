class Comment < ApplicationRecord
  acts_as_paranoid

  include Filterable

  belongs_to :author, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  validates :message, length: { maximum: 200 }

  has_many :comments, as: :resource, dependent: :destroy

  scope :publics, -> { where(private: false) }

  def self.privates(choice)
    where(private: choice.to_s.to_b)
  end

  def of_comment?
    resource_type == 'Comment'
  end
end
