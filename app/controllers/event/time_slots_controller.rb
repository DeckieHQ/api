class Event::TimeSlotsController < ApplicationController
  before_action :authenticate

  def index
    search = Search.new(params, sort: %w(created_at begin_at))

    return render_search_errors(search) unless search.valid?

    render json: search.apply(event.time_slots), scope: current_user
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end
end
