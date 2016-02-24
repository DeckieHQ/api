class SubscriptionsController < ApplicationController
  before_action :authenticate!

  def create
    event_service = EventService.new(event)

    subscription = event_service.subscribe(current_user.profile)

    return render_validation_errors(event_service) unless subscription

    render json: subscription, status: :created
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end
end
