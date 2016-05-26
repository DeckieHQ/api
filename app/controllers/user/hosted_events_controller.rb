class User::HostedEventsController < ApplicationController
  before_action :authenticate!

  def index
    search = Search.new(params, sort: %w(begin_at end_at), filters: { scopes: [:opened] })

    return render_search_errors(search) unless search.valid?

    render json: search.apply(current_user.hosted_events)
  end

  def create
    authorize Event

    unless current_user.hosted_events << hosted_event
      return render_validation_errors(hosted_event)
    end
    render json: hosted_event, status: :created
  end

  protected

  def hosted_event
    @hosted_event ||= Event.new(event_params)
  end

  def event_params
    permited_attributes(Event)
  end
end
