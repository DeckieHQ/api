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

    subscribtion = SubscribeEvent.new(current_user, event).call

    render json: subscribtion, status: :created
  end

  def show
    authorize subscription

    render json: subscription
  end

  def confirm
    authorize subscription

    render json: ConfirmSubscription.new(subscription).call
  end

  def destroy
    authorize subscription

    CancelSubscription.new(subscription).call

    head :no_content
  end

  protected

  def event
    @event ||= Event.find(params[:event_id])
  end

  def subscription
    @subscription ||= Subscription.find(params[:id])
  end
end
