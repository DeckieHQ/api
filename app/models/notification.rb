class Notification < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :user
  belongs_to :action

  before_create :set_type

  scope :remainings_count, -> { where(viewed: false).count }

  def viewed!
    update(viewed: true)
  end

  private

  def set_type
    self.type = "#{action.target_type.downcase}-#{action.type}"
  end
end
