class TimeSlotSubmissionsController < ApplicationController
  before_action :authenticate!

  def show
    authorize time_slot_submission

    render json: time_slot_submission
  end

  def destroy
    authorize time_slot_submission

    CancelTimeSlotSubmission.new(time_slot_submission).call

    head :no_content
  end

  protected

  def time_slot_submission
    @time_slot_submission ||= TimeSlotSubmission.find(params[:id])
  end
end
