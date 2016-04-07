class Notification < ApplicationRecord
  include Filterable

  self.inheritance_column = nil

  belongs_to :user
  belongs_to :action

  before_create :set_type

  def viewed!
    update(viewed: true)
  end

  def send_email
    if user.preferences[:notifications].include?(type)
      UserMailer.send_notification(self).deliver_later
    end
  end

  private

  def set_type
    self.type = "#{action.resource_type.downcase}-#{action.type}"
  end
end
