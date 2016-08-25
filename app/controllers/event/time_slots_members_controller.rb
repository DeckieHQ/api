class Event::TimeSlotsMembersController < ApplicationController
  def index
    search = Search.new(params, include: %w(time_slot_submissions))

    return render_search_errors(search) unless search.valid?

    render json: search.apply(event.time_slots_members), include: search.included
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end
end
