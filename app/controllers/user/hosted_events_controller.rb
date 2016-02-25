class User::HostedEventsController < ApplicationController

  delegate :hosted_events, to: :current_user

  before_action :authenticate!

  before_action :verified!, only: :create

  before_action :event, only: :update

  before_action -> { check_parameters_for :events }, only: [:create, :update]

  def index
    search = Search.new(params, sort: %w(begin_at end_at), filters: { scopes: [:opened] })

    return render_search_errors(search) unless search.valid?

    render json: search.apply(hosted_events)
  end

  def show
    render json: event
  end

  def create
    event = Event.new(event_params)

    return render_validation_errors(event) unless hosted_events << event

    render json: event, status: :created
  end

  def update
    unless event_service.update(event_params)
      return render_validation_errors(event_service)
    end
    render json: event
  end

  def destroy
    return render_validation_errors(event_service) unless event_service.destroy

    head :no_content
  end

  protected

  def event
    @event ||= hosted_events.find(params[:id])
  end

  def event_service
    @event_service ||= EventService.new(event)
  end

  def event_params
    resource_attributes.permit(
     :title, :category, :ambiance, :level, :capacity, :auto_accept, :description,
     :begin_at, :end_at, :street, :postcode, :city, :state, :country
    )
  end
end
