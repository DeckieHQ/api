class Users::VerificationsController < ApplicationController
  before_action :authenticate!

  before_action :retrieve_verification

  def create
    return head :no_content if @verification.send_instructions

    render_validation_errors(@verification) and return
  end

  def update
    return head :no_content if @verification.complete

    render_validation_errors(@verification) and return
  end

  protected

  def retrieve_verification
    @verification = Verification.new(params[:verification], user: current_user)
  end
end
