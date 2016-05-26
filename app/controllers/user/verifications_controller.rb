class User::VerificationsController < ApplicationController
  before_action :authenticate!

  def create
    unless verification.valid?
      return render_validation_errors(verification)
    end

    authorize verification

    result = SendVerification.new(current_user, verification).call

    unless result.instructions_sent?
      return render_service_error(result)
    end
    head :no_content
  end

  def update
    unless verification.valid?(:complete)
      return render_validation_errors(verification)
    end

    CompleteVerification.new(current_user, verification).call

    head :no_content
  end

  protected

  def verification
    @verification ||= Verification.new(verification_params, model: current_user)
  end

  def verification_params
    attributes(:verifications).permit(:type, :token)
  end
end
