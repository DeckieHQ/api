class Verification
  include ActiveModel::Validations

  attr_accessor :type, :token

  validates :type,  inclusion: { in: %w(email phone_number) }

  validates :token, presence: true, on: :complete

  validate :token_must_be_valid, on: :complete, if: :verify_token?

  def initialize(attributes = {}, model: nil)
    # Allow type to be set with a symbol for conveniency.
    @type  = (attributes[:type]  || '').to_s
    @token = (attributes[:token] || '').to_s
    @model = model
  end

  # def send_instructions
  #   return false unless valid? && valid?(:send_instructions)
  #
  #   model.send("generate_#{type}_verification_token!")
  #
  #   sent = model.send("send_#{type}_verification_instructions")
  #
  #   errors.add(:base, :unassigned, base_error_options) unless sent
  #
  #   sent
  # end
  #
  # def complete
  #   return false unless valid? && valid?(:complete)
  #
  #   model.send("verify_#{type}!")
  # end

  private

  attr_reader :model

  def token_must_be_valid
    model_token = model.send("#{type}_verification_token")

    if token != model_token.to_s || expired?
      errors.add(:token, :invalid)
    end
  end

  def expired?
    model.send("#{type}_verification_sent_at") < 5.hours.ago
  end

  def verify_token?
    errors.empty?
  end
end
