class User::HostedEventsController < ApplicationController
  before_action :authenticate!

  before_action :retrieve_event

  def show
    render json: @event, status: :ok
  end

  protected

  def retrieve_event
    @event = current_user.hosted_events.find_by(id: params[:id])

    render_error_for(:not_found) unless @event
  end
end
