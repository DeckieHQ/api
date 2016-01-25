class VerificationsService
  def initialize(model, params)
    @model   = model
    @params  = params[:verification] || {}
  end

  def exist?
    ['email', 'phone_number'].include?(type)
  end

  def already_verified?
    @model.send("#{type}_verified_at").present?
  end

  def token_valid?
    @model.send("#{type}_verification_token") == token
  end

  def token_expired?
    @model.send("#{type}_verification_sent_at") + 5.hours > Time.now
  end

  def send_instructions
    @model.send("generate_#{type}_verification_token!")
    @model.send("send_#{type}_verification_instructions")
  end

  def complete!
    @model.send("verify_#{type}!")
  end

  def type
    @type ||= (@params[:type] || '')
  end

  private

  # TODO: Rethink this whole idea of token/pin
  def token
    @token_attribute ||= type == 'phone_number' ? :pin : :token

    @token ||= (@params[@token_attribute] || '')
  end
end

class Users::VerificationsController < ApplicationController
  before_action :authenticate!

  before_action :retrieve_verification

  def create
    @verification.send_instructions

    head :no_content and return
  end

  def update
    unless @verification.token_valid?
      return render_verification_error :token_invalid, status: :forbidden
    end
    unless @verification.token_expired?
      return render_verification_error :token_expired, status: :gone
    end

    @verification.complete!

    render json: current_user, status: :ok and return
  end

  protected

  def retrieve_verification
    @verification = VerificationsService.new(current_user, params)

    return render_not_found unless @verification.exist?

    if @verification.already_verified?
      return render_verification_error :already_verified, status: :conflict
    end
  end

  def render_verification_error(error_type, status:)
    error_message = I18n.t(
      "verifications.failure.#{error_type}", type: @verification.type
    )
    render json: { error: error_message }, status: status
  end
end
