class TimeSlotsController < ApplicationController
  def show
    render json: time_slot
  end

  private

  def time_slot
    @time_slot ||= TimeSlot.find(params[:id])
  end
end
