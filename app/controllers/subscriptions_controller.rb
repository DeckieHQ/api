class SubscriptionsController < ApplicationController
  before_action :authenticate!

  def index
    authorize event, :subscriptions?

    search = Search.new(params,
      sort: %w(created_at), include: %w(profile), filters: { scopes: [:status] }
    )
    return render_search_errors(search) unless search.valid?

    render json: search.apply(event.subscriptions), include: search.included
  end

  def create
    authorize event, :subscribe?

    event_service = EventService.new(event)

    unless new_subscription = event_service.subscribe(current_user.profile)
      return render_validation_errors(event_service)
    end
    render json: new_subscription, status: :created
  end

  def show
    authorize subscription

    render json: subscription
  end

  def confirm
    authorize subscription

    unless subscribtion_service.confirm
      return render_validation_errors(subscribtion_service)
    end
    render json: subscription
  end

  def destroy
    authorize subscription

    unless subscribtion_service.destroy
      return render_validation_errors(subscribtion_service)
    end
    head :no_content
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end

  def subscription
    @subscription ||= Subscription.find(params[:id])
  end

  def subscribtion_service
    @subscription_service ||= SubscriptionService.new(subscription)
  end
end
