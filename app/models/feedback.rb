class Feedback
  include ActiveModel::Validations

  attr_accessor :title, :description, :email

  validates :title, :description, presence: true

  validates :title, length: { maximum: 128 }

  validates :description, length: { maximum: 8192 }

  validates :email, email: true, allow_nil: true

  def initialize(attributes = {})
    @title       = attributes[:title]
    @description = attributes[:description]
    @email       = attributes[:email]
  end

  def send_informations
    FeedbackMailer.informations(self).deliver_now
  end
end
