class Action < ApplicationRecord
  acts_as_paranoid without_default_scope: true

  self.inheritance_column = nil

  attr_accessor :notify

  belongs_to :actor, -> { with_deleted }, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  belongs_to :top_resource, polymorphic: true

  before_create :set_title

  before_create :set_receivers_ids

  before_create :set_top_resource

  after_commit :create_notifications

  private

  def set_title
    self.title = resource.title
  end

  def set_receivers_ids
    self.receivers_ids = resource.receivers_ids_for(self)
  end

  def set_top_resource
    self.top_resource = resource.top_resource
  end

  def create_notifications
    case notify
    when :now
      ActionNotifierJob.perform_now(self)
    when :later
      ActionNotifierJob.perform_later(self)
    end
  end
end
