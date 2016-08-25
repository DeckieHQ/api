class TimeSlotSubmissionsController < ApplicationController
  before_action :authenticate!

  def create
    authorize time_slot, :join?

    render json: JoinTimeSlot.new(time_slot, current_user.profile).call, status: 201
  end

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

  def time_slot
    @time_slot ||= TimeSlot.find(params[:time_slot_id])
  end
end
