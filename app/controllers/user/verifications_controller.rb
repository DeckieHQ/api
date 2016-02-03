class User::VerificationsController < ApplicationController
  before_action :authenticate!

  before_action -> { check_root_for :verification }

  before_action :retrieve_verification

  def create
    return head :no_content if @verification.send_instructions

    render_validation_errors(@verification)
  end

  def update
    return head :no_content if @verification.complete

    render_validation_errors(@verification)
  end

  protected

  def retrieve_verification
    @verification = Verification.new(params[:verification], model: current_user)
  end
end
