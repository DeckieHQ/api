class Feedback
  include ActiveModel::Validations

  attr_accessor :title, :description

  validates :title, :description, presence: true

  validates :title, length: { maximum: 128 }

  validates :description, length: { maximum: 8192 }

  def send_email
    FeedbackMailer.informations(self).deliver_later
  end
end
