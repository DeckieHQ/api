class Event::ChildrenController < ApplicationController
  def index
    search = Search.new(params, sort: %w(begin_at))

    return render_search_errors(search) unless search.valid?

    render json: search.apply(event.children)
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end
end
