class TimeSlotSubmissionsController < ApplicationController
  before_action :authenticate!

  def show
    authorize time_slot_submission

    render json: time_slot_submission
  end

  protected

  def time_slot_submission
    @time_slot_submission ||= TimeSlotSubmission.find(params[:id])
  end
end
