class SubscriptionsController < ApplicationController
  before_action :authenticate!

  def index
    return render_error_for(:forbidden) unless event_host?

    search = Search.new(params, sort: %w(created_at), filters: [:status])

    return render_search_errors(search) unless search.valid?

    render json: search.apply(event.subscriptions)
  end

  def create
    event_service = EventService.new(event)

    unless new_subscription = event_service.subscribe(current_profile)
      return render_validation_errors(event_service)
    end
    render json: new_subscription, status: :created
  end

  def show
    unless subscriber? || event_host?
      return render_error_for(:forbidden)
    end
    render json: subscription
  end

  def confirm
    return render_error_for(:forbidden) unless event_host?

    unless subscribtion_service.confirm
      return render_validation_errors(subscribtion_service)
    end
    render json: subscription
  end

  def destroy
    return render_error_for(:forbidden) unless subscriber?

    unless subscribtion_service.destroy
      return render_validation_errors(subscribtion_service)
    end
    head :no_content
  end

  protected

  def event
    @event ||= retrieve_event
  end

  def subscription
    @subscription ||= Subscription.find(params[:id])
  end

  def subscribtion_service
    @subscription_service ||= SubscriptionService.new(subscription)
  end

  def subscriber?
    current_profile == subscription.profile
  end

  def event_host?
    current_profile == event.host
  end

  private

  def retrieve_event
    event_id = params[:event_id]

    event_id.present? ? Event.find(event_id) : subscription.event
  end
end
