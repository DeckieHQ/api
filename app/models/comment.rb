class Comment < ApplicationRecord
  acts_as_paranoid

  include Filterable

  belongs_to :author, -> { with_deleted }, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  validates :message, presence: true, length: { maximum: 200 }

  has_many :comments, as: :resource, dependent: :destroy

  before_save :assigns_private, if: :of_comment?

  after_create :update_counter_cache

  after_destroy :update_counter_cache

  scope :publics, -> { where(private: false) }

  delegate :top_resource, to: :resource

  def title
    message.first(40)
  end

  def receivers_ids_for(action)
    comments.pluck(:profile_id).push(author.id).tap { |ids| ids.delete(action.actor.id) }
  end

  def self.privates(choice)
    where(private: choice.to_s.to_b)
  end

  def of_comment?
    resource_type == 'Comment'
  end

  private

  def assigns_private
    self.private = resource.private
  end

  def update_counter_cache
    return resource.update(comments_count: resource.comments.count) if of_comment?

    resource.update({
      "#{counter_cache_prefix}_comments_count": resource.comments.privates(private?).count
    })
  end

  def counter_cache_prefix
    private? ? :private : :public
  end
end
