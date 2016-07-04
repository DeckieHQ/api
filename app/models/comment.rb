class Comment < ApplicationRecord
  acts_as_paranoid

  include Filterable

  belongs_to :author, -> { with_deleted }, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  validates :message, presence: true, length: { maximum: 200 }

  has_many :comments, as: :resource, dependent: :destroy

  after_create :update_counter_cache, unless: :of_comment?

  scope :publics, -> { where(private: false) }

  def title
    message.first(40)
  end

  def receivers_ids_for(action)
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

  private

  def update_counter_cache
    resource.update({
      "#{counter_cache_prefix}_comments_count": resource.comments.privates(private?).count
    })
  end

  def counter_cache_prefix
    private? ? :private : :public
  end
end
