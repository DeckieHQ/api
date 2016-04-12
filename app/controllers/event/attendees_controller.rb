class Event::AttendeesController < ApplicationController
  def index
    search = Search.new(params, sort: %w(created_at))

    return render_search_errors(search) unless search.valid?

    render json: search.apply(event.attendees)
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end
end
