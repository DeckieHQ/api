class Verification
  include ActiveModel::Validations

  attr_accessor :type, :token, :model

  validates :type, inclusion: { in: %w(email phone_number) }

  validate :model_attribute_must_be_speficied, on: :send_instructions

  validate :model_attribute_must_be_unverified, on: [:send_instructions, :complete]

  validate :token_must_be_valid, on: :complete

  def initialize(attributes = {}, model: nil)
    attributes = attributes || {}

    # Allow type to be set with a symbol for conveniency.
    @type  = (attributes[:type]  || '').to_s
    @token =  attributes[:token] || ''
    @model = model
  end

  def send_instructions
    return false unless valid? && valid?(:send_instructions)

    @model.send("generate_#{@type}_verification_token!")
    @model.send("send_#{@type}_verification_instructions")
  end

  def complete
    return false unless valid? && valid?(:complete)

    @model.send("verify_#{@type}!")
  end

  private

  def model_attribute_must_be_speficied
    model_attribute = @model.send("#{type}")

    errors.add(:base, :unspecified, base_error_options) unless model_attribute
  end

  def model_attribute_must_be_unverified
    attribute_verified_at = @model.send("#{@type}_verified_at")

    errors.add(:base, :already_verified, base_error_options) if attribute_verified_at
  end

  def token_must_be_valid
    model_token = @model.send("#{@type}_verification_token")

    if @token.blank? || @token.to_s != model_token.to_s || sent_at < 5.hours.ago
      errors.add(:token, :invalid)
    end
  end

  def sent_at
    @model.send("#{@type}_verification_sent_at")
  end

  def base_error_options
    { target: @model.class.name.to_sym, type: @type }
  end
end
