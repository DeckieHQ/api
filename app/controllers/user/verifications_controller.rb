class User::VerificationsController < ApplicationController
  before_action :authenticate!

  def create
    authorize verification if verification.valid?

    unless verification.send_instructions
      return render_validation_errors(verification)
    end
    head :no_content
  end

  def update
    authorize verification if verification.valid?

    unless verification.complete
      return render_validation_errors(verification)
    end
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
