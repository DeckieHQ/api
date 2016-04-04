class Action < ApplicationRecord
  acts_as_paranoid

  self.inheritance_column = nil

  attr_accessor :notify

  belongs_to :actor, class_name: 'Profile', foreign_key: 'profile_id'

  belongs_to :resource, polymorphic: true

  before_create :set_title

  before_create :set_receiver_ids

  after_commit :create_notifications

  private

  def set_title
    self.title = resource.title
  end

  def set_receiver_ids
    self.receiver_ids = resource.receiver_ids_for(self)
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
