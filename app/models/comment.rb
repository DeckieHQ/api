class Comment < ApplicationRecord
  acts_as_paranoid

  include Filterable

  belongs_to :author, -> { with_deleted }, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  validates :message, length: { maximum: 200 }

  has_many :comments, as: :resource, dependent: :destroy

  scope :publics, -> { where(private: false) }

  def title
    message[0...40]
  end

  def receiver_ids_for(action)
    ids = comments.pluck(:profile_id).push(author.id)

    ids.delete(action.actor.id)

    ids
  end

  def self.privates(choice)
    where(private: choice.to_s.to_b)
  end

  def of_comment?
    resource_type == 'Comment'
  end
end
