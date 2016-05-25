class Verification
  include ActiveModel::Validations

  attr_accessor :type, :token

  attr_reader :model

  validates :type,  inclusion: { in: %w(email phone_number) }

  validates :token, presence: true, on: :complete

  validate :token_must_be_valid, on: :complete, if: :verify_token?

  def initialize(attributes = {}, model: nil)
    # Allow type to be set with a symbol for conveniency.
    @type  = (attributes[:type]  || '').to_s
    @token = (attributes[:token] || '').to_s
    @model = model
  end

  private

  def token_must_be_valid
    model_token = model.send("#{type}_verification_token").to_s

    errors.add(:token, :invalid) if token != model_token || expired?
  end

  def expired?
    model.send("#{type}_verification_sent_at") < 5.hours.ago
  end

  def verify_token?
    errors.empty?
  end
end
