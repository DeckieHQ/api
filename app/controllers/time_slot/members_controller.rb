class TimeSlot::MembersController < ApplicationController
  def index
    search = Search.new(params, sort: %w(created_at))

    return render_search_errors(search) unless search.valid?

    render json: search.apply(time_slot.members)
  end

  protected

  def time_slot
    @time_slot ||= TimeSlot.find(params[:time_slot_id])
  end
end
