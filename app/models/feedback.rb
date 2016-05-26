class Feedback
  include ActiveModel::Validations

  attr_accessor :title, :description

  validates :title, :description, presence: true

  validates :title, length: { maximum: 128 }

  validates :description, length: { maximum: 8192 }

  def initialize(attributes = {})
    @title       = attributes[:title]
    @description = attributes[:description]
  end

  def send_informations
    FeedbackMailer.informations(self).deliver_now
  end
end
