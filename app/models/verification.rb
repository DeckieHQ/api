class Verification
  include ActiveModel::Validations

  attr_accessor :type, :token

  attr_reader :model

  validates :type, inclusion: { in: %w(email phone_number) }

  validate :token_must_be_valid, on: :complete

  def initialize(attributes = {}, model: nil)
    # Allow type to be set with a symbol for conveniency.
    @type  = (attributes[:type]  || '').to_s
    @token = (attributes[:token] || '').to_s
    @model = model
  end

  def send_instructions
    return false unless valid? && valid?(:send_instructions)

    model.send("generate_#{type}_verification_token!")

    sent = model.send("send_#{type}_verification_instructions")

    errors.add(:base, :unassigned, base_error_options) unless sent

    sent
  end

  def complete
    return false unless valid? && valid?(:complete)

    model.send("verify_#{type}!")
  end

  private

  def token_must_be_valid
    model_token = model.send("#{type}_verification_token")

    if token.blank? || token != model_token.to_s || sent_at < 5.hours.ago
      errors.add(:token, :invalid)
    end
  end

  def sent_at
    model.send("#{type}_verification_sent_at")
  end

  def base_error_options
    { target: model.class.name.to_sym, type: type }
  end
end
