class SubscriptionsController < ApplicationController
  before_action :authenticate!

  def create
    event_service = EventService.new(event)

    subscription = event_service.subscribe(current_profile)

    return render_validation_errors(event_service) unless subscription

    render json: subscription, status: :created
  end

  def show
    unless subscriber? || event_host?
      return render_error_for(:forbidden)
    end
    render json: subscription
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end

  def subscription
    @subscription ||= event.subscriptions.find(params[:id])
  end

  def subscriber?
    current_profile == subscription.profile
  end

  def event_host?
    current_profile == event.host
  end
end
