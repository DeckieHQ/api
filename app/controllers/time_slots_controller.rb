class TimeSlotsController < ApplicationController
  before_action :authenticate!, only: :destroy

  def show
    render json: time_slot
  end

  def destroy
    authorize time_slot
    
    time_slot.destroy

    head :no_content
  end

  private

  def time_slot
    @time_slot ||= TimeSlot.find(params[:id])
  end
end
