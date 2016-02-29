class User::HostedEventsController < ApplicationController
  before_action :authenticate!

  before_action :verified!, only: :create

  before_action -> { check_parameters_for :events }, only: :create

  def index
    search = Search.new(params, sort: %w(begin_at end_at), filters: { scopes: [:opened] })

    return render_search_errors(search) unless search.valid?

    render json: search.apply(current_user.hosted_events)
  end

  def create
    event = Event.new(event_params)

    unless current_user.hosted_events << event
      return render_validation_errors(event)
    end
    render json: event, status: :created
  end

  protected

  def event_params
    resource_attributes.permit(
     :title, :category, :ambiance, :level, :capacity, :auto_accept, :description,
     :begin_at, :end_at, :street, :postcode, :city, :state, :country
    )
  end
end
