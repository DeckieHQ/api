class User::HostedEventsController < ApplicationController
  delegate :hosted_events, to: :current_user

  before_action :authenticate!

  before_action :verified_user!, only: :create

  before_action :retrieve_event, only: [:show, :destroy]

  before_action :event_not_started!, only: :destroy

  before_action -> { check_parameters_for :events }, only: :create

  def show
    render json: @event, status: :ok
  end

  def create
    event = Event.new(event_params)

    return render_validation_errors(event) unless hosted_events << event

    render json: event, status: :created
  end

  def destroy
    @event.destroy

    head :no_content
  end

  protected

  def retrieve_event
    @event = hosted_events.find_by(id: params[:id])

    render_error_for(:not_found) unless @event
  end

  def event_not_started!
    return unless @event.already_started?

    @event.errors.add(:base, :already_started)

    render_validation_errors(@event)
  end

  def event_params
    resource_attributes.permit(
     :title, :category, :ambiance, :level, :capacity, :invite_only, :description,
     :begin_at, :end_at, :street, :postcode, :city,
     :state, :country
    )
  end
end
